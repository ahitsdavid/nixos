#!/usr/bin/env bash
# install.sh — Full NixOS installation wizard
#
# Usage:
#   scripts/install.sh [options]
#
# Supports:
#   - Local mode: running from the custom ISO on the target machine
#   - Remote mode: running over SSH to a machine booted from the ISO
#   - Partition schemes: plain, LUKS-encrypted, LUKS + LVM
#   - Filesystems: ext4, btrfs, xfs, f2fs, bcachefs
#
# Options:
#   --remote <host>   Install to a remote machine via SSH
#   --hostname <name> Pre-set the target hostname
#   --disk <device>   Pre-set the target disk
#   --no-encrypt      Skip encryption prompts
#   -h, --help        Show usage
#
set -euo pipefail

# ── Helpers ──────────────────────────────────────────────────────────────────

# Detect repo root: prefer git repo, fall back to ISO baked-in config
REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || true)"
if [[ -z "$REPO_ROOT" ]]; then
  if [[ -d /etc/nixos-config/.git ]]; then
    REPO_ROOT="/etc/nixos-config"
  else
    echo "Error: Must be run inside the nixos git repository (or from the installer ISO)."
    exit 1
  fi
fi
IS_ISO=false
if [[ "$REPO_ROOT" == "/etc/nixos-config" ]]; then
  IS_ISO=true
fi

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

info()  { echo -e "${CYAN}[info]${NC}  $*"; }
ok()    { echo -e "${GREEN}[ok]${NC}    $*"; }
warn()  { echo -e "${YELLOW}[warn]${NC}  $*"; }
err()   { echo -e "${RED}[error]${NC} $*" >&2; }

check_tool() {
  local cmd="$1"
  if [[ -n "${REMOTE_HOST:-}" ]]; then
    if ! ssh -o ConnectTimeout=5 "root@$REMOTE_HOST" "command -v $cmd" &>/dev/null; then
      err "Required tool '$cmd' not found on remote host."
      exit 1
    fi
  else
    if ! command -v "$cmd" &>/dev/null; then
      err "Required tool '$cmd' not found."
      exit 1
    fi
  fi
}

prompt_default() {
  local prompt="$1" default="$2" var_name="$3"
  read -rp "$(echo -e "${CYAN}$prompt${NC} [$default]: ")" value
  eval "$var_name=\"${value:-$default}\""
}

prompt_required() {
  local prompt="$1" var_name="$2"
  local value=""
  while [[ -z "$value" ]]; do
    read -rp "$(echo -e "${CYAN}$prompt${NC}: ")" value
    [[ -z "$value" ]] && warn "This field is required."
  done
  eval "$var_name=\"$value\""
}

prompt_yn() {
  local prompt="$1" default="$2" var_name="$3"
  local yn_hint
  if [[ "$default" == "y" ]]; then
    yn_hint="Y/n"
  else
    yn_hint="y/N"
  fi
  read -rp "$(echo -e "${CYAN}$prompt${NC} [$yn_hint]: ")" answer
  answer="${answer:-$default}"
  if [[ "${answer,,}" == "y" ]]; then
    eval "$var_name=true"
  else
    eval "$var_name=false"
  fi
}

prompt_choice() {
  local prompt="$1" var_name="$2"
  shift 2
  local options=("$@")
  local count=${#options[@]}

  echo ""
  echo -e "${CYAN}$prompt${NC}"
  for i in "${!options[@]}"; do
    echo "  $((i+1))) ${options[$i]}"
  done

  local choice
  while true; do
    read -rp "$(echo -e "${CYAN}Choice${NC} [1-$count]: ")" choice
    if [[ "$choice" =~ ^[0-9]+$ ]] && (( choice >= 1 && choice <= count )); then
      eval "$var_name=\"${options[$((choice-1))]}\""
      return
    fi
    warn "Invalid choice. Enter a number between 1 and $count."
  done
}

# ── Remote execution wrapper ─────────────────────────────────────────────────

run_cmd() {
  if [[ -n "${REMOTE_HOST:-}" ]]; then
    ssh -o StrictHostKeyChecking=accept-new "root@$REMOTE_HOST" "$@"
  else
    eval "$@"
  fi
}

# ── Disk detection ───────────────────────────────────────────────────────────

detect_disks() {
  echo ""
  info "Detecting available disks..."
  echo ""

  local disk_list
  disk_list=$(run_cmd "lsblk -dpno NAME,SIZE,MODEL,TYPE 2>/dev/null | grep 'disk' | grep -v 'loop\|sr[0-9]'" || true)

  if [[ -z "$disk_list" ]]; then
    err "No disks detected."
    exit 1
  fi

  local disks=()
  local i=1
  while IFS= read -r line; do
    disks+=("$line")
    echo "  $i) $line"
    ((i++))
  done <<< "$disk_list"

  echo ""
  local choice
  while true; do
    read -rp "$(echo -e "${CYAN}Select target disk${NC} [1-${#disks[@]}]: ")" choice
    if [[ "$choice" =~ ^[0-9]+$ ]] && (( choice >= 1 && choice <= ${#disks[@]} )); then
      TARGET_DISK=$(echo "${disks[$((choice-1))]}" | awk '{print $1}')
      break
    fi
    warn "Invalid choice."
  done

  echo ""
  echo -e "${RED}╔══════════════════════════════════════════════════════════════╗${NC}"
  echo -e "${RED}║  WARNING: ALL DATA ON $TARGET_DISK WILL BE DESTROYED!      ${NC}"
  echo -e "${RED}╚══════════════════════════════════════════════════════════════╝${NC}"
  echo ""
  prompt_yn "Are you absolutely sure?" "n" confirm_disk
  if [[ "$confirm_disk" != "true" ]]; then
    info "Aborted."
    exit 0
  fi
}

# ── Partition naming ─────────────────────────────────────────────────────────

partition_name() {
  local disk="$1" num="$2"
  if [[ "$disk" == *nvme* || "$disk" == *mmcblk* ]]; then
    echo "${disk}p${num}"
  else
    echo "${disk}${num}"
  fi
}

# ── Partitioning schemes ────────────────────────────────────────────────────

do_partition_plain() {
  local disk="$1"
  info "Creating GPT partition table (plain, no encryption)..."

  run_cmd "parted -s $disk -- mklabel gpt"
  run_cmd "parted -s $disk -- mkpart ESP fat32 1MiB 512MiB"
  run_cmd "parted -s $disk -- set 1 esp on"
  run_cmd "parted -s $disk -- mkpart primary 512MiB 100%"

  BOOT_PART=$(partition_name "$disk" 1)
  ROOT_PART=$(partition_name "$disk" 2)
  LUKS_PART=""
  LVM_VG=""

  ok "Partitioned $disk (ESP + root)"
}

do_partition_luks() {
  local disk="$1"
  info "Creating GPT partition table (LUKS encrypted)..."

  run_cmd "parted -s $disk -- mklabel gpt"
  run_cmd "parted -s $disk -- mkpart ESP fat32 1MiB 512MiB"
  run_cmd "parted -s $disk -- set 1 esp on"
  run_cmd "parted -s $disk -- mkpart primary 512MiB 100%"

  BOOT_PART=$(partition_name "$disk" 1)
  LUKS_PART=$(partition_name "$disk" 2)
  LVM_VG=""

  echo ""
  info "Setting up LUKS encryption on $LUKS_PART..."
  warn "You will be prompted for a passphrase."
  echo ""

  if [[ -n "${REMOTE_HOST:-}" ]]; then
    # For remote: interactive passphrase entry through SSH
    ssh -t "root@$REMOTE_HOST" "cryptsetup luksFormat --type luks2 $LUKS_PART"
    ssh -t "root@$REMOTE_HOST" "cryptsetup luksOpen $LUKS_PART cryptroot"
  else
    cryptsetup luksFormat --type luks2 "$LUKS_PART"
    cryptsetup luksOpen "$LUKS_PART" cryptroot
  fi

  ROOT_PART="/dev/mapper/cryptroot"
  ok "LUKS encryption configured"
}

do_partition_luks_lvm() {
  local disk="$1"
  info "Creating GPT partition table (LUKS + LVM)..."

  run_cmd "parted -s $disk -- mklabel gpt"
  run_cmd "parted -s $disk -- mkpart ESP fat32 1MiB 512MiB"
  run_cmd "parted -s $disk -- set 1 esp on"
  run_cmd "parted -s $disk -- mkpart primary 512MiB 100%"

  BOOT_PART=$(partition_name "$disk" 1)
  LUKS_PART=$(partition_name "$disk" 2)
  LVM_VG="vg0"

  echo ""
  info "Setting up LUKS encryption on $LUKS_PART..."
  warn "You will be prompted for a passphrase."
  echo ""

  if [[ -n "${REMOTE_HOST:-}" ]]; then
    ssh -t "root@$REMOTE_HOST" "cryptsetup luksFormat --type luks2 $LUKS_PART"
    ssh -t "root@$REMOTE_HOST" "cryptsetup luksOpen $LUKS_PART cryptlvm"
  else
    cryptsetup luksFormat --type luks2 "$LUKS_PART"
    cryptsetup luksOpen "$LUKS_PART" cryptlvm
  fi

  ok "LUKS encryption configured"

  # LVM setup
  info "Setting up LVM..."
  run_cmd "pvcreate /dev/mapper/cryptlvm"
  run_cmd "vgcreate $LVM_VG /dev/mapper/cryptlvm"

  # Swap
  prompt_default "Swap size (e.g., 8G, 16G, 0 for none)" "8G" swap_size
  SWAP_PART=""
  if [[ "$swap_size" != "0" ]]; then
    run_cmd "lvcreate -L ${swap_size} $LVM_VG -n swap"
    SWAP_PART="/dev/$LVM_VG/swap"
  fi

  run_cmd "lvcreate -l 100%FREE $LVM_VG -n root"
  ROOT_PART="/dev/$LVM_VG/root"

  ok "LVM configured (VG: $LVM_VG)"
}

# ── Filesystem formatting ───────────────────────────────────────────────────

format_filesystem() {
  local device="$1" fstype="$2"

  info "Formatting $device as $fstype..."
  case "$fstype" in
    ext4)     run_cmd "mkfs.ext4 -F $device" ;;
    btrfs)    run_cmd "mkfs.btrfs -f $device" ;;
    xfs)      run_cmd "mkfs.xfs -f $device" ;;
    f2fs)     run_cmd "mkfs.f2fs -f $device" ;;
    bcachefs) run_cmd "bcachefs format $device" ;;
    *)        err "Unknown filesystem: $fstype"; exit 1 ;;
  esac
  ok "Formatted $device as $fstype"

  info "Formatting boot partition ($BOOT_PART) as FAT32..."
  run_cmd "mkfs.fat -F 32 $BOOT_PART"
  ok "Boot partition formatted"
}

# ── Btrfs subvolumes ────────────────────────────────────────────────────────

create_btrfs_subvolumes() {
  local device="$1"

  prompt_yn "Create btrfs subvolumes? (@, @home)" "y" use_subvols
  if [[ "$use_subvols" == "true" ]]; then
    info "Creating btrfs subvolumes..."
    run_cmd "mount $device /mnt"
    run_cmd "btrfs subvolume create /mnt/@"
    run_cmd "btrfs subvolume create /mnt/@home"
    run_cmd "umount /mnt"
    BTRFS_SUBVOLS=true
    ok "Created subvolumes: @, @home"
  else
    BTRFS_SUBVOLS=false
  fi
}

# ── Mounting ─────────────────────────────────────────────────────────────────

mount_filesystems() {
  info "Mounting filesystems to /mnt..."

  if [[ "${BTRFS_SUBVOLS:-false}" == "true" ]]; then
    run_cmd "mount -o subvol=@,compress=zstd $ROOT_PART /mnt"
    run_cmd "mkdir -p /mnt/home"
    run_cmd "mount -o subvol=@home,compress=zstd $ROOT_PART /mnt/home"
  else
    run_cmd "mount $ROOT_PART /mnt"
  fi

  run_cmd "mkdir -p /mnt/boot"
  run_cmd "mount $BOOT_PART /mnt/boot"

  # Swap (LVM only)
  if [[ -n "${SWAP_PART:-}" ]]; then
    run_cmd "mkswap $SWAP_PART"
    run_cmd "swapon $SWAP_PART"
    ok "Swap enabled on $SWAP_PART"
  fi

  ok "Filesystems mounted to /mnt"
}

# ── Hardware config generation ───────────────────────────────────────────────

generate_hardware_config() {
  local hostname="$1"

  info "Generating hardware configuration..."
  run_cmd "nixos-generate-config --root /mnt"
  ok "Hardware configuration generated"

  local target_dir="$REPO_ROOT/hosts/$hostname"
  mkdir -p "$target_dir"

  if [[ -n "${REMOTE_HOST:-}" ]]; then
    scp "root@$REMOTE_HOST:/mnt/etc/nixos/hardware-configuration.nix" "$target_dir/hardware-configuration.nix"
  else
    cp /mnt/etc/nixos/hardware-configuration.nix "$target_dir/hardware-configuration.nix"
  fi
  ok "Copied hardware-configuration.nix to hosts/$hostname/"
}

# ── Clone repo to target ────────────────────────────────────────────────────

clone_repo_to_target() {
  info "Setting up NixOS config on target..."

  if [[ -n "${REMOTE_HOST:-}" ]]; then
    # Ensure git is available on remote
    run_cmd "command -v git >/dev/null 2>&1 || nix-env -iA nixpkgs.git"

    # Copy the repo to the target
    info "Copying configuration to remote host..."
    run_cmd "mkdir -p /mnt/etc"
    scp -r "$REPO_ROOT" "root@$REMOTE_HOST:/mnt/etc/nixos-config"
    ok "Configuration copied to /mnt/etc/nixos-config"
  else
    # Local mode: copy repo to target
    if [[ ! -d /mnt/etc/nixos-config ]]; then
      run_cmd "mkdir -p /mnt/etc"
      cp -r "$REPO_ROOT" /mnt/etc/nixos-config
      ok "Configuration copied to /mnt/etc/nixos-config"
    else
      ok "Configuration already present at /mnt/etc/nixos-config"
    fi
  fi

  # Commit hardware-config so the flake can see it
  # (NixOS flakes require all files to be tracked by git)
  local config_dir
  if [[ -n "${REMOTE_HOST:-}" ]]; then
    config_dir="/mnt/etc/nixos-config"
    run_cmd "cd $config_dir && git add hosts/$INSTALL_HOSTNAME/hardware-configuration.nix && git commit -m 'Add hardware-configuration.nix for $INSTALL_HOSTNAME' --no-gpg-sign || true"
  else
    config_dir="/mnt/etc/nixos-config"
    (cd "$config_dir" && git add "hosts/$INSTALL_HOSTNAME/hardware-configuration.nix" && git commit -m "Add hardware-configuration.nix for $INSTALL_HOSTNAME" --no-gpg-sign) || true
  fi
  ok "Hardware config committed to git"
}

# ── NixOS installation ──────────────────────────────────────────────────────

run_nixos_install() {
  local hostname="$1"

  echo ""
  info "Running nixos-install..."
  info "This may take a while depending on your connection and hardware."
  echo ""

  run_cmd "nixos-install --root /mnt --flake /mnt/etc/nixos-config#$hostname --no-root-passwd"

  ok "NixOS installation completed!"
}

# ── Post-install ─────────────────────────────────────────────────────────────

post_install() {
  local hostname="$1"

  echo ""
  info "Post-installation setup..."

  # Get username from flake
  local username
  username=$(grep -oP 'username = "\K[^"]+' "$REPO_ROOT/flake.nix")

  # Copy SOPS age key if it exists
  local age_key="$HOME/.config/sops/age/keys.txt"
  if [[ -f "$age_key" ]]; then
    prompt_yn "Copy SOPS age key to the new installation?" "y" copy_sops
    if [[ "$copy_sops" == "true" ]]; then
      local target_age="/mnt/home/$username/.config/sops/age"
      run_cmd "mkdir -p $target_age"
      if [[ -n "${REMOTE_HOST:-}" ]]; then
        scp "$age_key" "root@$REMOTE_HOST:$target_age/keys.txt"
        run_cmd "chmod 600 $target_age/keys.txt"
      else
        cp "$age_key" "$target_age/keys.txt"
        chmod 600 "$target_age/keys.txt"
      fi
      ok "SOPS age key copied"

      # Also copy to system location for sops-nix
      run_cmd "mkdir -p /mnt/var/lib/sops-nix"
      if [[ -n "${REMOTE_HOST:-}" ]]; then
        scp "$age_key" "root@$REMOTE_HOST:/mnt/var/lib/sops-nix/key.txt"
        run_cmd "chmod 600 /mnt/var/lib/sops-nix/key.txt"
      else
        cp "$age_key" /mnt/var/lib/sops-nix/key.txt
        chmod 600 /mnt/var/lib/sops-nix/key.txt
      fi
      ok "SOPS key copied to /var/lib/sops-nix/key.txt"
    fi
  else
    warn "No SOPS age key found at $age_key"
    info "You can set one up later with: scripts/setup-secrets.sh bootstrap"
  fi

  # Set user password
  echo ""
  info "Set a password for user '$username':"
  if [[ -n "${REMOTE_HOST:-}" ]]; then
    ssh -t "root@$REMOTE_HOST" "nixos-enter --root /mnt -- passwd $username"
  else
    nixos-enter --root /mnt -- passwd "$username"
  fi
  ok "Password set for $username"
}

# ── Host selection ───────────────────────────────────────────────────────────

select_host() {
  echo ""
  info "Available host configurations:"
  echo ""

  local hosts=()
  for d in "$REPO_ROOT"/hosts/*/; do
    [[ -d "$d" ]] || continue
    local hname hdesc
    hname=$(basename "$d")
    hdesc=$(grep -oP 'description\s*=\s*"\K[^"]+' "$d/meta.nix" 2>/dev/null || echo "")
    hosts+=("$hname")
    echo "  - $hname${hdesc:+ ($hdesc)}"
  done
  echo ""

  prompt_yn "Use an existing host configuration?" "y" use_existing
  if [[ "$use_existing" == "true" ]]; then
    prompt_required "Which host" INSTALL_HOSTNAME
    if [[ ! -d "$REPO_ROOT/hosts/$INSTALL_HOSTNAME" ]]; then
      err "Host '$INSTALL_HOSTNAME' not found."
      exit 1
    fi
  else
    info "You should scaffold a new host first."
    echo ""
    prompt_yn "Run add-host.sh now to scaffold a new host?" "y" run_scaffold
    if [[ "$run_scaffold" == "true" ]]; then
      "$REPO_ROOT/scripts/add-host.sh"
      echo ""
      prompt_required "Enter the hostname you just created" INSTALL_HOSTNAME
    else
      prompt_required "Enter the hostname to install" INSTALL_HOSTNAME
      if [[ ! -d "$REPO_ROOT/hosts/$INSTALL_HOSTNAME" ]]; then
        err "Host '$INSTALL_HOSTNAME' not found. Create it first with: scripts/add-host.sh"
        exit 1
      fi
    fi
  fi
}

# ── Main ─────────────────────────────────────────────────────────────────────

main() {
  echo ""
  echo -e "${GREEN}══════════════════════════════════════════════════════════════${NC}"
  echo -e "${GREEN}  NixOS Installation Wizard${NC}"
  echo -e "${GREEN}══════════════════════════════════════════════════════════════${NC}"
  echo ""

  # Mode detection
  if [[ -n "${REMOTE_HOST:-}" ]]; then
    info "Mode: Remote installation to $REMOTE_HOST"
    info "Testing SSH connectivity..."
    if ssh -o ConnectTimeout=5 "root@$REMOTE_HOST" true 2>/dev/null; then
      ok "SSH connection to $REMOTE_HOST successful"
    else
      err "Cannot connect to root@$REMOTE_HOST"
      info "Make sure the target is booted from the NixOS ISO and SSH is enabled."
      info "Default ISO credentials: root / nixos"
      exit 1
    fi
  else
    info "Mode: Local installation"
    if [[ $EUID -ne 0 ]]; then
      warn "Not running as root. Some operations will require sudo."
    fi
  fi

  # Step 1: Host selection
  if [[ -n "${PRE_HOSTNAME:-}" ]]; then
    INSTALL_HOSTNAME="$PRE_HOSTNAME"
    if [[ ! -d "$REPO_ROOT/hosts/$INSTALL_HOSTNAME" ]]; then
      err "Host '$INSTALL_HOSTNAME' not found."
      exit 1
    fi
    info "Using pre-set hostname: $INSTALL_HOSTNAME"
  else
    select_host
  fi

  # Step 2: Disk selection
  if [[ -n "${PRE_DISK:-}" ]]; then
    TARGET_DISK="$PRE_DISK"
    info "Using pre-set disk: $TARGET_DISK"
    echo ""
    echo -e "${RED}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${RED}║  WARNING: ALL DATA ON $TARGET_DISK WILL BE DESTROYED!      ${NC}"
    echo -e "${RED}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    prompt_yn "Are you absolutely sure?" "n" confirm_disk
    if [[ "$confirm_disk" != "true" ]]; then
      info "Aborted."
      exit 0
    fi
  else
    detect_disks
  fi

  # Step 3: Partition scheme
  local partition_scheme_choice
  if [[ "${NO_ENCRYPT:-false}" == "true" ]]; then
    partition_scheme_choice="Plain (no encryption)"
  else
    prompt_choice "Partition scheme:" partition_scheme_choice \
      "Plain (no encryption)" \
      "LUKS (encrypted root)" \
      "LUKS + LVM (encrypted with logical volumes)"
  fi

  # Step 4: Filesystem
  local filesystem_choice
  prompt_choice "Root filesystem:" filesystem_choice \
    "ext4 (reliable, widely supported)" \
    "btrfs (snapshots, compression, subvolumes)" \
    "xfs (high performance, large files)" \
    "f2fs (optimized for flash/SSD)" \
    "bcachefs (next-gen, copy-on-write)"

  # Extract just the filesystem name
  local fstype
  fstype=$(echo "$filesystem_choice" | awk '{print $1}')

  # Step 5: Btrfs subvolumes (if applicable)
  BTRFS_SUBVOLS=false

  # Step 6: Swap (only for non-LVM plain/LUKS schemes)
  SWAP_PART=""
  local create_swapfile=false
  local swapfile_size=""
  if [[ "$partition_scheme_choice" != LUKS\ +\ LVM* ]]; then
    prompt_yn "Create a swap file?" "y" create_swapfile
    if [[ "$create_swapfile" == "true" ]]; then
      prompt_default "Swap file size" "8G" swapfile_size
    fi
  fi

  # Step 7: Confirmation summary
  echo ""
  echo -e "${GREEN}──────────────────────────────────────────────────────────────${NC}"
  echo -e "${GREEN}  Installation Summary${NC}"
  echo -e "${GREEN}──────────────────────────────────────────────────────────────${NC}"
  echo ""
  info "  Hostname:     $INSTALL_HOSTNAME"
  info "  Target disk:  $TARGET_DISK"
  info "  Partitioning: ${partition_scheme_choice%% (*}"
  info "  Filesystem:   $fstype"
  if [[ "$fstype" == "btrfs" ]]; then
    info "  Subvolumes:   (will be prompted)"
  fi
  if [[ "$partition_scheme_choice" == LUKS\ +\ LVM* ]]; then
    info "  Swap:         (configured in LVM)"
  elif [[ "$create_swapfile" == "true" ]]; then
    info "  Swap file:    $swapfile_size"
  else
    info "  Swap:         none"
  fi
  if [[ -n "${REMOTE_HOST:-}" ]]; then
    info "  Mode:         Remote ($REMOTE_HOST)"
  else
    info "  Mode:         Local"
  fi
  echo ""

  prompt_yn "Proceed with installation?" "n" proceed
  if [[ "$proceed" != "true" ]]; then
    info "Aborted."
    exit 0
  fi

  # ── Execute installation steps ──

  echo ""
  echo -e "${GREEN}══════════════════════════════════════════════════════════════${NC}"
  echo -e "${GREEN}  Beginning Installation${NC}"
  echo -e "${GREEN}══════════════════════════════════════════════════════════════${NC}"
  echo ""

  local start_time
  start_time=$(date +%s)

  # Step A: Partition disk
  info "Step 1/7: Partitioning disk..."
  case "$partition_scheme_choice" in
    Plain*)      do_partition_plain "$TARGET_DISK" ;;
    LUKS\ \(*)   do_partition_luks "$TARGET_DISK" ;;
    LUKS\ +*)    do_partition_luks_lvm "$TARGET_DISK" ;;
  esac
  echo ""

  # Step B: Format filesystem
  info "Step 2/7: Formatting filesystem..."
  format_filesystem "$ROOT_PART" "$fstype"
  echo ""

  # Step C: Btrfs subvolumes
  if [[ "$fstype" == "btrfs" ]]; then
    info "Step 3/7: Btrfs subvolumes..."
    create_btrfs_subvolumes "$ROOT_PART"
  else
    info "Step 3/7: Skipping subvolumes (not btrfs)"
  fi
  echo ""

  # Step D: Mount filesystems
  info "Step 4/7: Mounting filesystems..."
  mount_filesystems

  # Create swap file (non-LVM)
  if [[ "$create_swapfile" == "true" && -n "$swapfile_size" ]]; then
    info "Creating ${swapfile_size} swap file..."
    run_cmd "dd if=/dev/zero of=/mnt/swapfile bs=1M count=$((${swapfile_size%G} * 1024)) status=progress"
    run_cmd "chmod 600 /mnt/swapfile"
    run_cmd "mkswap /mnt/swapfile"
    run_cmd "swapon /mnt/swapfile"
    ok "Swap file created and enabled"
  fi
  echo ""

  # Step E: Generate hardware config
  info "Step 5/7: Generating hardware configuration..."
  generate_hardware_config "$INSTALL_HOSTNAME"
  echo ""

  # Step F: Clone repo to target
  info "Step 6/7: Setting up configuration on target..."
  clone_repo_to_target
  echo ""

  # Step G: Run nixos-install
  info "Step 7/7: Installing NixOS..."
  run_nixos_install "$INSTALL_HOSTNAME"
  echo ""

  # Post-install
  post_install "$INSTALL_HOSTNAME"

  local end_time elapsed
  end_time=$(date +%s)
  elapsed=$((end_time - start_time))

  # Success
  echo ""
  echo -e "${GREEN}══════════════════════════════════════════════════════════════${NC}"
  ok "NixOS installation completed in ${elapsed}s!"
  echo -e "${GREEN}══════════════════════════════════════════════════════════════${NC}"
  echo ""
  info "Next steps:"
  info "  1. Reboot into the new installation"
  if [[ -n "${REMOTE_HOST:-}" ]]; then
    info "     ssh root@$REMOTE_HOST reboot"
  else
    info "     reboot"
  fi
  info "  2. Log in as your user"
  info "  3. Move config to permanent location:"
  info "     mv /etc/nixos-config ~/nixos && cd ~/nixos"
  info "  4. Connect to Tailscale: sudo tailscale up"
  info "  5. Set up secrets (SOPS age key):"
  info "     scripts/setup-secrets.sh bootstrap"
  info "  6. Deploy to apply secrets and finalize:"
  info "     scripts/deploy.sh $INSTALL_HOSTNAME"
  echo ""
  info "Available scripts for ongoing management:"
  info "  scripts/deploy.sh <host>           Deploy config (local or remote)"
  info "  scripts/setup-secrets.sh verify    Verify secrets are decryptable"
  info "  scripts/add-host.sh               Scaffold a new host"
  info "  scripts/add-user.sh --add         Add an additional user to a host"
  echo ""

  if [[ -n "${LUKS_PART:-}" ]]; then
    info "LUKS partition: $LUKS_PART"
    info "You will be prompted for your passphrase on each boot."
  fi
}

# ── Argument parsing ─────────────────────────────────────────────────────────

usage() {
  echo "Usage: $0 [options]"
  echo ""
  echo "Full NixOS installation wizard."
  echo ""
  echo "Supports local (from ISO) and remote (SSH to ISO-booted machine) modes."
  echo "Handles partitioning, encryption (LUKS), LVM, and multiple filesystems."
  echo ""
  echo "Options:"
  echo "  --remote <host>   Install to a remote machine via SSH"
  echo "  --hostname <name> Pre-set the target hostname (skip prompt)"
  echo "  --disk <device>   Pre-set the target disk (skip detection)"
  echo "  --no-encrypt      Skip encryption prompts (plain partitioning)"
  echo "  -h, --help        Show this help message"
  echo ""
  echo "Examples:"
  echo "  $0                              # Interactive local install"
  echo "  $0 --remote 192.168.1.50        # Remote install via SSH"
  echo "  $0 --hostname desktop --disk /dev/nvme0n1"
  echo "  $0 --no-encrypt                 # Skip encryption options"
  echo ""
  echo "Supported partition schemes:"
  echo "  - Plain: GPT with ESP + root (no encryption)"
  echo "  - LUKS: GPT with ESP + LUKS2-encrypted root"
  echo "  - LUKS + LVM: GPT with ESP + LUKS2 + LVM (root + swap LVs)"
  echo ""
  echo "Supported filesystems:"
  echo "  - ext4: Standard, reliable"
  echo "  - btrfs: Snapshots, compression, subvolumes"
  echo "  - xfs: High performance"
  echo "  - f2fs: Flash/SSD optimized"
  echo "  - bcachefs: Next-gen copy-on-write"
}

# Parse arguments
REMOTE_HOST=""
PRE_HOSTNAME=""
PRE_DISK=""
NO_ENCRYPT=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --remote)
      REMOTE_HOST="$2"; shift 2 ;;
    --hostname)
      PRE_HOSTNAME="$2"; shift 2 ;;
    --disk)
      PRE_DISK="$2"; shift 2 ;;
    --no-encrypt)
      NO_ENCRYPT=true; shift ;;
    -h|--help)
      usage; exit 0 ;;
    *)
      err "Unknown option: $1"
      echo ""
      usage
      exit 1 ;;
  esac
done

main
