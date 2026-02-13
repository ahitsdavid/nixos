#!/usr/bin/env bash
# add-host.sh — Scaffold a new NixOS host configuration
#
# Usage:
#   scripts/add-host.sh           # Interactive host scaffolding
#   scripts/add-host.sh --help    # Show usage
#
set -euo pipefail

# ── Helpers ──────────────────────────────────────────────────────────────────

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || true)"
if [[ -z "$REPO_ROOT" ]]; then
  echo "Error: Must be run inside the nixos git repository."
  exit 1
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

# ── Validation ───────────────────────────────────────────────────────────────

get_existing_hosts() {
  local hosts=()
  for d in "$REPO_ROOT"/hosts/*/; do
    [[ -d "$d" ]] && hosts+=("$(basename "$d")")
  done
  echo "${hosts[@]}"
}

get_existing_ssh_aliases() {
  local aliases=()
  for meta in "$REPO_ROOT"/hosts/*/meta.nix; do
    [[ -f "$meta" ]] || continue
    local alias_val
    alias_val=$(grep -oP 'sshAlias\s*=\s*"\K[^"]+' "$meta" 2>/dev/null || true)
    if [[ -n "$alias_val" ]]; then
      local host_name
      host_name=$(basename "$(dirname "$meta")")
      aliases+=("$alias_val ($host_name)")
    fi
  done
  echo "${aliases[@]}"
}

validate_hostname() {
  local name="$1"
  if [[ ! "$name" =~ ^[a-z][a-z0-9-]*$ ]]; then
    err "Invalid hostname. Must start with a lowercase letter, contain only [a-z0-9-]."
    return 1
  fi
  if [[ -d "$REPO_ROOT/hosts/$name" ]]; then
    err "Host directory 'hosts/$name' already exists."
    return 1
  fi
  if grep -q "hostname = \"$name\"" "$REPO_ROOT/flake.nix" 2>/dev/null; then
    err "Host '$name' already defined in flake.nix."
    return 1
  fi
  return 0
}

validate_ssh_alias() {
  local alias="$1"
  if [[ -z "$alias" ]]; then
    err "SSH alias cannot be empty."
    return 1
  fi
  for meta in "$REPO_ROOT"/hosts/*/meta.nix; do
    [[ -f "$meta" ]] || continue
    if grep -q "sshAlias = \"$alias\"" "$meta" 2>/dev/null; then
      local host_name
      host_name=$(basename "$(dirname "$meta")")
      err "SSH alias '$alias' already used by host '$host_name'."
      return 1
    fi
  done
  return 0
}

# ── Copy from existing host ───────────────────────────────────────────────────

read_host_config() {
  local source_host="$1"
  local meta_file="$REPO_ROOT/hosts/$source_host/meta.nix"
  local default_file="$REPO_ROOT/hosts/$source_host/default.nix"

  # Read from meta.nix
  if [[ -f "$meta_file" ]]; then
    is_gaming=$(grep -oP 'isGaming\s*=\s*\K(true|false)' "$meta_file" 2>/dev/null || echo "false")
    is_headless=$(grep -oP 'isHeadless\s*=\s*\K(true|false)' "$meta_file" 2>/dev/null || echo "false")
    is_laptop=$(grep -oP 'isLaptop\s*=\s*\K(true|false)' "$meta_file" 2>/dev/null || echo "false")
    uses_gnome=$(grep -oP 'usesGnome\s*=\s*\K(true|false)' "$meta_file" 2>/dev/null || echo "false")
    has_nvidia=$(grep -oP 'hasNvidia\s*=\s*\K(true|false)' "$meta_file" 2>/dev/null || echo "false")
  else
    err "No meta.nix found for host '$source_host'."
    return 1
  fi

  # Read from default.nix
  if [[ ! -f "$default_file" ]]; then
    err "No default.nix found for host '$source_host'."
    return 1
  fi

  # Detect GPU driver from meta.nix hybridGpu or hasNvidia
  if grep -q "hybridGpu" "$meta_file" 2>/dev/null; then
    gpu_driver="hybrid"
    has_nvidia="true"
    hybrid_mode=$(grep -oP 'mode\s*=\s*"\K[^"]+' "$meta_file" 2>/dev/null || echo "sync")
    intel_bus_id=$(grep -oP 'intelBusId\s*=\s*"\K[^"]+' "$meta_file" 2>/dev/null || echo "PCI:0:2:0")
    nvidia_bus_id=$(grep -oP 'nvidiaBusId\s*=\s*"\K[^"]+' "$meta_file" 2>/dev/null || echo "PCI:1:0:0")
  elif [[ "$has_nvidia" == "true" ]]; then
    gpu_driver="nvidia"
    hybrid_mode=""
    intel_bus_id=""
    nvidia_bus_id=""
  else
    gpu_driver="intel"
    hybrid_mode=""
    intel_bus_id=""
    nvidia_bus_id=""
  fi

  # Derive desktop_env
  if [[ "$is_headless" == "true" ]]; then
    desktop_env="none"
  elif [[ "$uses_gnome" == "true" ]]; then
    desktop_env="gnome"
  else
    desktop_env="hyprland"
  fi

  # Detect isDevelopment / isWork from meta.nix (default true for GUI hosts)
  enable_dev=$(grep -oP 'isDevelopment\s*=\s*\K(true|false)' "$meta_file" 2>/dev/null || echo "true")
  enable_work=$(grep -oP 'isWork\s*=\s*\K(true|false)' "$meta_file" 2>/dev/null || echo "true")

  # Detect kernel from default.nix
  if grep -q "linuxPackages_zen" "$default_file" 2>/dev/null; then
    kernel_package="linuxPackages_zen"
    kernel_choice="zen (optimized, gaming-focused)"
  elif grep -q "linuxPackages_latest" "$default_file" 2>/dev/null; then
    kernel_package="linuxPackages_latest"
    kernel_choice="latest (recommended)"
  else
    kernel_package="linuxPackages"
    kernel_choice="lts (long-term support, maximum stability)"
  fi

  ok "Copied configuration from '$source_host'"
}

# ── Generators ───────────────────────────────────────────────────────────────

generate_meta_nix() {
  cat <<NIXEOF
# Host metadata for SSH aliases and other tooling
{
  sshAlias = "$ssh_alias";
  description = "$host_description";

  # Capabilities
  hasNvidia = $has_nvidia;
  isGaming = $is_gaming;
  isHeadless = $is_headless;
  isLaptop = $is_laptop;
NIXEOF

  if [[ "$uses_gnome" == "true" ]]; then
    echo "  usesGnome = true; # Use GNOME instead of Hyprland"
  fi

  # isDevelopment / isWork: only emit if non-default (default is true for GUI hosts)
  if [[ "$is_headless" != "true" ]]; then
    if [[ "$enable_dev" == "false" ]]; then
      echo "  isDevelopment = false;"
    fi
    if [[ "$enable_work" == "false" ]]; then
      echo "  isWork = false;"
    fi
  fi

  # Hybrid GPU config
  if [[ "$gpu_driver" == "hybrid" ]]; then
    cat <<NIXEOF

  # Hybrid GPU: $hybrid_mode mode
  hybridGpu = {
    mode = "$hybrid_mode";
    intelBusId = "$intel_bus_id";
    nvidiaBusId = "$nvidia_bus_id";
  };
NIXEOF
  fi

  echo "}"
}

generate_default_nix() {
  # ── Header ──
  if [[ "$is_headless" == "true" ]]; then
    generate_default_nix_headless
    return
  fi

  # Profiles, drivers, and GPU config are auto-applied by host-builders.nix
  # based on meta.nix flags. Only host-specific config goes here.

  cat <<NIXEOF
{ config, pkgs, inputs, username, lib, ... }: {
  imports = [
    ./hardware-configuration.nix
  ];

  # Kernel
  boot.kernelPackages = pkgs.$kernel_package;

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
NIXEOF

  # ── GNOME host-specific extensions ──
  if [[ "$uses_gnome" == "true" ]]; then
    cat <<'NIXEOF'

  # GNOME tweaks and extensions
  environment.systemPackages = with pkgs; [
    gnome-tweaks
    gnome-extension-manager
    gnomeExtensions.caffeine
    gnomeExtensions.appindicator
    gnomeExtensions.dash-to-dock
    gnomeExtensions.clipboard-indicator
    gnomeExtensions.blur-my-shell
    gnomeExtensions.vitals
  ];
NIXEOF
  fi

  # ── Hostname and stateVersion ──
  cat <<NIXEOF

  networking.hostName = "$hostname";

  # stateVersion: Set at initial install - do not change
  system.stateVersion = "$state_version";
}
NIXEOF
}

generate_default_nix_headless() {
  cat <<NIXEOF
# Headless server configuration
{ config, pkgs, inputs, username, ... }:
let
  userVars = import ../../lib/user-vars.nix username;
in
{
  imports = [
    ./hardware-configuration.nix
    ../../profiles/ssh
  ];

  # Boot
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.$kernel_package;

  # Networking
  networking.hostName = "$hostname";
  networking.networkmanager.enable = true;
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 22 ];
  };

  # User account
  users.users.\${username} = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
  };

  # Tailscale for easy access from other machines
  services.tailscale.enable = true;

  # Nix configuration
  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      auto-optimise-store = true;
      trusted-users = [ "root" "@wheel" username ];
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 14d";
    };
  };

  # Git configuration (no home-manager on headless server)
  programs.git = {
    enable = true;
    config = {
      user.name = userVars.gitUsername;
      user.email = userVars.gitEmail;
    };
  };

  # Basic packages for administration
  environment.systemPackages = with pkgs; [
    htop
    curl
    vim
  ];

  # stateVersion: Set at initial install - do not change
  system.stateVersion = "$state_version";
}
NIXEOF
}

generate_hardware_placeholder() {
  # Check if we can copy from the current machine
  if [[ -f /etc/nixos/hardware-configuration.nix ]]; then
    echo ""
    prompt_yn "Found /etc/nixos/hardware-configuration.nix on this machine. Copy it?" "y" copy_hw
    if [[ "$copy_hw" == "true" ]]; then
      cp /etc/nixos/hardware-configuration.nix "$1"
      ok "Copied hardware-configuration.nix from /etc/nixos/"
      return
    fi
  fi

  cat > "$1" <<'NIXEOF'
# PLACEHOLDER — Replace with your actual hardware configuration
#
# ══════════════════════════════════════════════════════════════
# Step 1: Partition your disk (on the target machine)
# ══════════════════════════════════════════════════════════════
#
# Example: GPT + EFI + ext4 (simple setup)
#
#   sudo parted /dev/sdX -- mklabel gpt
#   sudo parted /dev/sdX -- mkpart ESP fat32 1MiB 512MiB
#   sudo parted /dev/sdX -- set 1 esp on
#   sudo parted /dev/sdX -- mkpart primary 512MiB 100%
#   sudo mkfs.fat -F 32 /dev/sdX1
#   sudo mkfs.ext4 /dev/sdX2
#
# Example: GPT + EFI + btrfs with subvolumes
#
#   sudo parted /dev/sdX -- mklabel gpt
#   sudo parted /dev/sdX -- mkpart ESP fat32 1MiB 512MiB
#   sudo parted /dev/sdX -- set 1 esp on
#   sudo parted /dev/sdX -- mkpart primary 512MiB 100%
#   sudo mkfs.fat -F 32 /dev/sdX1
#   sudo mkfs.btrfs /dev/sdX2
#   sudo mount /dev/sdX2 /mnt
#   sudo btrfs subvolume create /mnt/@
#   sudo btrfs subvolume create /mnt/@home
#   sudo umount /mnt
#   sudo mount -o subvol=@ /dev/sdX2 /mnt
#   sudo mkdir -p /mnt/{home,boot}
#   sudo mount -o subvol=@home /dev/sdX2 /mnt/home
#   sudo mount /dev/sdX1 /mnt/boot
#
# ══════════════════════════════════════════════════════════════
# Step 2: Mount and generate hardware config
# ══════════════════════════════════════════════════════════════
#
#   sudo mount /dev/sdX2 /mnt          # root partition
#   sudo mkdir -p /mnt/boot
#   sudo mount /dev/sdX1 /mnt/boot     # EFI partition
#   sudo nixos-generate-config --root /mnt
#
# Then copy the generated file:
#   cp /mnt/etc/nixos/hardware-configuration.nix hosts/<hostname>/
#
# Or if NixOS is already installed and running:
#   sudo nixos-generate-config --show-hardware-config > hosts/<hostname>/hardware-configuration.nix
#
# ══════════════════════════════════════════════════════════════

{ config, lib, pkgs, modulesPath, ... }: {
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  # TODO: Replace everything below with your generated hardware config

  boot.initrd.availableKernelModules = [ ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/REPLACE-ME";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/REPLACE-ME";
    fsType = "vfat";
  };

  swapDevices = [ ];

  networking.useDHCP = lib.mkDefault true;
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
NIXEOF

  # Replace <hostname> placeholder with the actual hostname
  sed -i "s|hosts/<hostname>/|hosts/$hostname/|g" "$1"
  ok "Created placeholder hardware-configuration.nix"
  warn "You must replace this with your real hardware config before building."
}

# ── Flake modification ───────────────────────────────────────────────────────

add_to_flake() {
  local flake_file="$REPO_ROOT/flake.nix"

  if [[ "$is_headless" == "true" ]]; then
    # Insert before the closing `};` of nixosConfigurations
    # Find the line with the existing headless entry (vm) and add after it
    sed -i "/vm = mkHeadlessConfiguration/a\\      $hostname = mkHeadlessConfiguration { hostname = \"$hostname\"; };" "$flake_file"
    ok "Added $hostname to flake.nix (headless)"
  else
    # Insert before the `# VM is headless` comment line
    sed -i "/# VM is headless/i\\      $hostname = mkNixosConfiguration { hostname = \"$hostname\"; };" "$flake_file"
    ok "Added $hostname to flake.nix (GUI)"

    # Add to all-systems list (only for GUI hosts)
    # Match the specific all-systems line (contains the host list array with "desktop")
    sed -i "/\"desktop\".*\"thinkpad\".*\"macbook\"/s|\"macbook\" \]|\"macbook\" \"$hostname\" ]|" "$flake_file"
    ok "Added $hostname to all-systems build list"
  fi
}

# ── Main ─────────────────────────────────────────────────────────────────────

main() {
  echo ""
  echo -e "${GREEN}══════════════════════════════════════════════════════════════${NC}"
  echo -e "${GREEN}  NixOS Configuration — New Host Scaffolding${NC}"
  echo -e "${GREEN}══════════════════════════════════════════════════════════════${NC}"
  echo ""
  info "This will create a new host configuration with boilerplate matching"
  info "existing hosts. You will be asked about DE, GPU, profiles, etc."
  echo ""

  # ── Hostname ──
  local hostname host_description
  while true; do
    prompt_required "Hostname (e.g. thinkpad, my-server)" hostname
    validate_hostname "$hostname" && break
  done
  prompt_required "Description (e.g. ThinkPad T480, Build server)" host_description

  # ── Configuration mode: copy or from scratch ──
  local desktop_env="hyprland" gpu_driver="none" uses_gnome="false"
  local has_nvidia="false" is_gaming="false" is_laptop="false" is_headless="false"
  local hybrid_mode="" intel_bus_id="" nvidia_bus_id=""
  local enable_dev="true" enable_work="false"
  local kernel_choice="" kernel_package=""
  local config_mode

  # Show existing hosts for reference
  echo ""
  info "Existing hosts:"
  for d in "$REPO_ROOT"/hosts/*/; do
    [[ -d "$d" ]] || continue
    local hname hdesc
    hname=$(basename "$d")
    hdesc=$(grep -oP 'description\s*=\s*"\K[^"]+' "$d/meta.nix" 2>/dev/null || echo "")
    echo "  - $hname${hdesc:+ ($hdesc)}"
  done

  local mode_choice
  prompt_choice "How would you like to configure this host?" mode_choice \
    "Copy from existing host (pre-fill settings)" \
    "Configure from scratch"

  if [[ "$mode_choice" == Copy* ]]; then
    # ── Copy from existing host ──
    local source_host
    prompt_required "Which host to copy from" source_host

    if [[ ! -d "$REPO_ROOT/hosts/$source_host" ]]; then
      err "Host '$source_host' not found in hosts/"
      exit 1
    fi

    read_host_config "$source_host"

    # For hybrid GPU, bus IDs are hardware-specific — prompt to confirm
    if [[ "$gpu_driver" == "hybrid" ]]; then
      echo ""
      warn "Hybrid GPU bus IDs are hardware-specific. Verify these match your new machine."
      info "Find them with: lspci | grep VGA"
      prompt_default "Intel Bus ID" "$intel_bus_id" intel_bus_id
      prompt_default "NVIDIA Bus ID" "$nvidia_bus_id" nvidia_bus_id
    fi
  else
    # ── Configure from scratch ──

    # Headless check
    prompt_yn "Is this a headless server (no GUI, no home-manager)?" "n" is_headless

    if [[ "$is_headless" == "true" ]]; then
      desktop_env="none"
      gpu_driver="none"
      uses_gnome="false"
      has_nvidia="false"
      is_gaming="false"
      is_laptop="false"
      enable_dev="false"
      enable_work="false"
    else
      # Desktop environment
      local de_choice
      prompt_choice "Desktop environment:" de_choice \
        "Hyprland (tiling Wayland compositor)" \
        "GNOME (traditional desktop, better touch support)"
      case "$de_choice" in
        Hyprland*) desktop_env="hyprland"; uses_gnome="false" ;;
        GNOME*)    desktop_env="gnome"; uses_gnome="true" ;;
      esac

      # GPU driver
      local gpu_choice
      prompt_choice "Graphics driver:" gpu_choice \
        "None (VM/basic, software rendering)" \
        "Intel (integrated graphics)" \
        "NVIDIA (dedicated GPU)" \
        "Hybrid Intel + NVIDIA (laptop)"
      case "$gpu_choice" in
        None*)   gpu_driver="none"; has_nvidia="false" ;;
        Intel*)  gpu_driver="intel"; has_nvidia="false" ;;
        NVIDIA*) gpu_driver="nvidia"; has_nvidia="true" ;;
        Hybrid*)
          gpu_driver="hybrid"; has_nvidia="true"
          # Hybrid mode
          local mode_choice
          prompt_choice "Hybrid GPU mode:" mode_choice \
            "sync (performance, for gaming — GPU always active)" \
            "offload (battery saving — GPU on demand)"
          case "$mode_choice" in
            sync*)    hybrid_mode="sync" ;;
            offload*) hybrid_mode="offload" ;;
          esac
          echo ""
          info "You need PCI bus IDs. Find them with: lspci | grep VGA"
          prompt_default "Intel Bus ID" "PCI:0:2:0" intel_bus_id
          prompt_default "NVIDIA Bus ID" "PCI:1:0:0" nvidia_bus_id
          ;;
      esac

      # Gaming
      prompt_yn "Enable gaming? (Steam, MangoHud, game launchers)" "n" is_gaming

      # Laptop
      prompt_yn "Is this a laptop? (power management, touchpad, backlight)" "n" is_laptop

      # Profiles
      echo ""
      prompt_yn "Enable development profile? (Docker, languages, dev tools)" "y" enable_dev
      prompt_yn "Enable work profile? (LibreOffice, printing, CAC/certs)" "n" enable_work
    fi
  fi

  # ── SSH alias ──
  echo ""
  info "Existing SSH aliases:"
  local has_aliases=false
  for meta in "$REPO_ROOT"/hosts/*/meta.nix; do
    [[ -f "$meta" ]] || continue
    local alias_val
    alias_val=$(grep -oP 'sshAlias\s*=\s*"\K[^"]+' "$meta" 2>/dev/null || true)
    if [[ -n "$alias_val" ]]; then
      local hname
      hname=$(basename "$(dirname "$meta")")
      echo "  - $alias_val ($hname)"
      has_aliases=true
    fi
  done
  if [[ "$has_aliases" == "false" ]]; then
    echo "  (none)"
  fi
  echo ""

  local ssh_alias
  while true; do
    prompt_required "SSH alias for Tailscale (short, e.g. 'st' for thinkpad)" ssh_alias
    validate_ssh_alias "$ssh_alias" && break
  done

  # ── Kernel (skip if already set by copy) ──
  if [[ -z "$kernel_package" ]]; then
    prompt_choice "Kernel:" kernel_choice \
      "latest (recommended)" \
      "zen (optimized, gaming-focused)" \
      "lts (long-term support, maximum stability)"
    case "$kernel_choice" in
      latest*) kernel_package="linuxPackages_latest" ;;
      zen*)    kernel_package="linuxPackages_zen" ;;
      lts*)    kernel_package="linuxPackages" ;;
    esac
  else
    info "Kernel: ${kernel_choice%% *} (from source host)"
  fi

  # ── State version ──
  local state_version
  prompt_default "NixOS state version" "25.11" state_version

  # ── Confirmation ──
  echo ""
  echo -e "${GREEN}──────────────────────────────────────────────────────────────${NC}"
  echo -e "${GREEN}  Configuration Summary${NC}"
  echo -e "${GREEN}──────────────────────────────────────────────────────────────${NC}"
  echo ""
  info "  Hostname:      $hostname"
  info "  Description:   $host_description"
  info "  SSH alias:     $ssh_alias"
  if [[ "$is_headless" == "true" ]]; then
    info "  Type:          Headless server (no GUI)"
  else
    if [[ "$uses_gnome" == "true" ]]; then
      info "  Type:          GUI (GNOME)"
    else
      info "  Type:          GUI (Hyprland)"
    fi
    info "  GPU:           $gpu_driver${hybrid_mode:+ ($hybrid_mode mode)}"
    info "  Gaming:        $([[ "$is_gaming" == "true" ]] && echo "yes" || echo "no")"
    info "  Laptop:        $([[ "$is_laptop" == "true" ]] && echo "yes" || echo "no")"
    info "  Development:   $([[ "$enable_dev" == "true" ]] && echo "yes" || echo "no")"
    info "  Work:          $([[ "$enable_work" == "true" ]] && echo "yes" || echo "no")"
  fi
  info "  Kernel:        ${kernel_choice%% *}"
  info "  State version: $state_version"
  echo ""

  read -rp "$(echo -e "${CYAN}Proceed? [Y/n]${NC}: ")" confirm
  [[ "${confirm,,}" == "n" ]] && { info "Aborted."; exit 0; }

  # ── Generate files ──
  echo ""
  local host_dir="$REPO_ROOT/hosts/$hostname"
  mkdir -p "$host_dir"

  generate_meta_nix > "$host_dir/meta.nix"
  ok "Created hosts/$hostname/meta.nix"

  generate_default_nix > "$host_dir/default.nix"
  ok "Created hosts/$hostname/default.nix"

  generate_hardware_placeholder "$host_dir/hardware-configuration.nix"

  # ── Modify flake.nix ──
  add_to_flake

  # ── Success ──
  echo ""
  echo -e "${GREEN}══════════════════════════════════════════════════════════════${NC}"
  ok "Host '$hostname' scaffolded successfully!"
  echo -e "${GREEN}══════════════════════════════════════════════════════════════${NC}"
  echo ""
  info "Created files:"
  info "  hosts/$hostname/default.nix"
  info "  hosts/$hostname/meta.nix"
  info "  hosts/$hostname/hardware-configuration.nix"
  echo ""
  info "Modified files:"
  info "  flake.nix"
  echo ""
  info "Next steps:"
  info "  1. Replace hosts/$hostname/hardware-configuration.nix with real config"
  info "     Run on target: sudo nixos-generate-config --show-hardware-config"
  info "  2. Review and customize hosts/$hostname/default.nix"
  info "  3. Commit: git add hosts/$hostname flake.nix && git commit -m 'Add host $hostname'"
  info "  4. Build: nixos-rebuild switch --flake .#$hostname"

  echo ""
  info "Profiles (base, development, work, laptop) and GPU drivers are auto-applied"
  info "by host-builders.nix based on meta.nix flags. Only host-specific overrides"
  info "go in default.nix."

  if [[ "$uses_gnome" == "true" ]]; then
    echo ""
    info "Note: GNOME hosts use minimal.nix for home-manager (set via usesGnome in meta.nix)."
    info "GNOME extensions are included in default.nix — customize as needed."
  fi

  if [[ "$gpu_driver" == "hybrid" ]]; then
    echo ""
    info "Note: Verify PCI bus IDs in meta.nix match your hardware (lspci | grep VGA)."
    info "Wrong bus IDs will cause boot issues."
  fi

  if [[ "$is_headless" == "true" ]]; then
    echo ""
    info "Note: Headless hosts have no home-manager. User config is in default.nix."
    info "SSH profile is included — ensure your SSH key is in the config."
  fi
}

# ── Entry point ──────────────────────────────────────────────────────────────

usage() {
  echo "Usage: $0 [--help]"
  echo ""
  echo "Interactively scaffold a new NixOS host configuration."
  echo ""
  echo "Creates:"
  echo "  hosts/<hostname>/default.nix               Main host config"
  echo "  hosts/<hostname>/meta.nix                   Host metadata"
  echo "  hosts/<hostname>/hardware-configuration.nix Hardware config (placeholder)"
  echo ""
  echo "Modifies:"
  echo "  flake.nix                                   Adds host to nixosConfigurations"
  echo ""
  echo "Options:"
  echo "  -h, --help    Show this help message"
}

case "${1:-}" in
  -h|--help) usage; exit 0 ;;
  "") main ;;
  *) usage; exit 1 ;;
esac
