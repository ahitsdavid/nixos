#!/usr/bin/env bash
# add-user.sh — Set up a new user for this NixOS configuration
#
# Usage:
#   scripts/add-user.sh --init    # Fork/fresh install: replace primary user
#   scripts/add-user.sh --add     # Add an additional user to a host
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

check_tool() {
  if ! command -v "$1" &>/dev/null; then
    err "Required tool '$1' not found. Please install it first."
    exit 1
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

# ── Generate variables.nix ──────────────────────────────────────────────────

generate_variables_nix() {
  local new_username="$1" fullname="$2" email="$3" shell="$4" browser="$5" terminal="$6"
  cat <<NIXEOF

{
  # Identity
  fullName = "$fullname";
  description = "$fullname";
  gitUsername = "$fullname";
  gitEmail = "$email";

  # System
  shell = "$shell";
  extraGroups = [ "networkmanager" "wheel" "docker" "libvirtd" "keys" ];

  # Hyprland Settings
  extraMonitorSettings = "";

  # Program Options
  browser = "$browser";
  terminal = "$terminal";
  file-manager = "yazi";
  keyboardLayout = "us";
  consoleKeyMap = "us";

  # Wallpaper
  wallpaper = "Pictures/Wallpapers/yosemite.png";

}
NIXEOF
}

# ── Setup SOPS age key ──────────────────────────────────────────────────────

setup_sops_age_key() {
  local new_username="$1"
  local age_dir="/home/${new_username}/.config/sops/age"
  local key_file="${age_dir}/keys.txt"

  echo ""
  info "Setting up SOPS age encryption key..."

  if [[ -f "$key_file" ]]; then
    ok "Age key already exists at $key_file"
    local pubkey
    pubkey=$(grep "public key:" "$key_file" | awk '{print $NF}')
    info "Public key: $pubkey"
  else
    check_tool age-keygen

    echo ""
    info "No age key found. Generating a new one..."
    mkdir -p "$age_dir"
    age-keygen -o "$key_file" 2>&1
    chmod 600 "$key_file"
    ok "Age key generated at $key_file"

    local pubkey
    pubkey=$(grep "public key:" "$key_file" | awk '{print $NF}')
    info "Public key: $pubkey"
  fi

  echo ""
  read -rp "$(echo -e "${CYAN}Update .sops.yaml &daily anchor with this public key? [y/N]${NC}: ")" update_sops
  if [[ "${update_sops,,}" == "y" ]]; then
    local sops_yaml="$REPO_ROOT/.sops.yaml"
    if [[ -f "$sops_yaml" ]]; then
      # Replace the &daily key line
      local old_key
      old_key=$(grep '&daily' "$sops_yaml" | sed 's/.*&daily //')
      if [[ -n "$old_key" ]]; then
        sed -i "s|$old_key|$pubkey|" "$sops_yaml"
        ok "Updated .sops.yaml &daily key to: $pubkey"
        warn "You will need to re-encrypt existing secrets with: sops updatekeys secrets/*.yaml"
      else
        warn "Could not find &daily anchor in .sops.yaml — please update manually."
      fi
    else
      warn ".sops.yaml not found at $sops_yaml"
    fi
  fi
}

# ── --init mode: Replace primary user ────────────────────────────────────────

do_init() {
  echo ""
  echo -e "${GREEN}══════════════════════════════════════════════════════════════${NC}"
  echo -e "${GREEN}  NixOS Configuration — Initial User Setup (Fork/Clone)${NC}"
  echo -e "${GREEN}══════════════════════════════════════════════════════════════${NC}"
  echo ""
  info "This will set up the primary user for this NixOS configuration."
  info "Your username will be set in flake.nix and a variables.nix will be generated."
  echo ""

  # Gather info
  prompt_required "Username (login name, lowercase)" new_username
  # Validate username
  if [[ ! "$new_username" =~ ^[a-z_][a-z0-9_-]*$ ]]; then
    err "Invalid username. Must start with lowercase letter or underscore, contain only [a-z0-9_-]."
    exit 1
  fi

  prompt_required "Full name (for git commits, display)" fullname
  prompt_required "Email address (for git config)" email
  prompt_default "Default shell" "fish" shell
  prompt_default "Default browser" "firefox" browser
  prompt_default "Default terminal" "kitty" terminal

  echo ""
  info "Summary:"
  info "  Username:  $new_username"
  info "  Full name: $fullname"
  info "  Email:     $email"
  info "  Shell:     $shell"
  info "  Browser:   $browser"
  info "  Terminal:  $terminal"
  echo ""
  read -rp "$(echo -e "${CYAN}Proceed? [Y/n]${NC}: ")" confirm
  [[ "${confirm,,}" == "n" ]] && { info "Aborted."; exit 0; }

  # 1. Create user directory
  local user_dir="$REPO_ROOT/home/users/$new_username"
  if [[ -d "$user_dir" ]]; then
    warn "Directory $user_dir already exists — will not overwrite variables.nix"
  else
    mkdir -p "$user_dir"
    generate_variables_nix "$new_username" "$fullname" "$email" "$shell" "$browser" "$terminal" \
      > "$user_dir/variables.nix"
    ok "Created $user_dir/variables.nix"

    # Copy face.png from existing user or create placeholder
    local existing_face="$REPO_ROOT/home/users/davidthach/face.png"
    if [[ -f "$existing_face" ]]; then
      cp "$existing_face" "$user_dir/face.png"
      ok "Copied face.png from davidthach"
    else
      warn "No face.png found — you'll need to add one at $user_dir/face.png"
      # Create a minimal placeholder so builds don't fail
      touch "$user_dir/face.png"
    fi
  fi

  # 2. Update flake.nix username
  local flake_file="$REPO_ROOT/flake.nix"
  local old_username
  old_username=$(grep -oP 'username = "\K[^"]+' "$flake_file")
  if [[ "$old_username" != "$new_username" ]]; then
    sed -i "s|username = \"$old_username\"|username = \"$new_username\"|" "$flake_file"
    ok "Updated flake.nix: username = \"$new_username\" (was: \"$old_username\")"
  else
    ok "flake.nix already has username = \"$new_username\""
  fi

  # 3. SOPS age key setup
  setup_sops_age_key "$new_username"

  # 4. Optional password hash
  echo ""
  read -rp "$(echo -e "${CYAN}Generate a login password hash now? [y/N]${NC}: ")" gen_pass
  if [[ "${gen_pass,,}" == "y" ]]; then
    check_tool mkpasswd
    echo ""
    info "Enter your desired login password:"
    local hash
    hash=$(mkpasswd -m sha-512)
    echo ""
    info "Password hash generated. Add this to secrets/personal.yaml under:"
    info "  users/$new_username/password_hash: |"
    echo "    $hash"
    echo ""
    warn "Use 'sops secrets/personal.yaml' to add this value."
  fi

  echo ""
  ok "Initial setup complete!"
  info "Next steps:"
  info "  1. Review the generated files"
  info "  2. If you updated .sops.yaml, re-encrypt: sops updatekeys secrets/*.yaml"
  info "  3. Commit and rebuild: git add -A && git commit -m 'Setup user $new_username'"
  info "  4. nixos-rebuild switch --flake .#<hostname>"
}

# ── --add mode: Add additional user ─────────────────────────────────────────

do_add() {
  echo ""
  echo -e "${GREEN}══════════════════════════════════════════════════════════════${NC}"
  echo -e "${GREEN}  NixOS Configuration — Add Additional User${NC}"
  echo -e "${GREEN}══════════════════════════════════════════════════════════════${NC}"
  echo ""
  info "This will add an additional user to a specific host."
  info "The user gets their own home-manager config and system account."
  echo ""

  # Gather info
  prompt_required "Username (login name, lowercase)" new_username
  if [[ ! "$new_username" =~ ^[a-z_][a-z0-9_-]*$ ]]; then
    err "Invalid username."
    exit 1
  fi

  prompt_required "Full name" fullname
  prompt_required "Email address" email
  prompt_default "Default shell" "fish" shell
  prompt_default "Default browser" "firefox" browser
  prompt_default "Default terminal" "kitty" terminal

  # Pick host
  echo ""
  info "Available hosts:"
  local hosts=()
  for d in "$REPO_ROOT"/hosts/*/; do
    local hname
    hname=$(basename "$d")
    hosts+=("$hname")
    echo "  - $hname"
  done
  echo ""
  prompt_required "Which host to add this user to" target_host

  # Validate host exists
  local host_dir="$REPO_ROOT/hosts/$target_host"
  if [[ ! -d "$host_dir" ]]; then
    err "Host '$target_host' not found in hosts/"
    exit 1
  fi

  echo ""
  info "Summary:"
  info "  Username:  $new_username"
  info "  Full name: $fullname"
  info "  Host:      $target_host"
  echo ""
  read -rp "$(echo -e "${CYAN}Proceed? [Y/n]${NC}: ")" confirm
  [[ "${confirm,,}" == "n" ]] && { info "Aborted."; exit 0; }

  # 1. Create user directory
  local user_dir="$REPO_ROOT/home/users/$new_username"
  if [[ -d "$user_dir" ]]; then
    warn "Directory $user_dir already exists — will not overwrite"
  else
    mkdir -p "$user_dir"
    generate_variables_nix "$new_username" "$fullname" "$email" "$shell" "$browser" "$terminal" \
      > "$user_dir/variables.nix"
    ok "Created $user_dir/variables.nix"

    # Copy face.png
    local existing_face="$REPO_ROOT/home/users/davidthach/face.png"
    if [[ -f "$existing_face" ]]; then
      cp "$existing_face" "$user_dir/face.png"
      ok "Copied default face.png"
    else
      touch "$user_dir/face.png"
      warn "No face.png found — placeholder created"
    fi
  fi

  # 2. Update host meta.nix to include extraUsers
  local meta_file="$host_dir/meta.nix"
  if [[ ! -f "$meta_file" ]]; then
    err "No meta.nix found for host '$target_host'."
    err "Create one at: $meta_file"
    exit 1
  fi

  # Check if extraUsers already exists in meta.nix
  if grep -q "extraUsers" "$meta_file"; then
    # Check if user is already listed
    if grep -q "\"$new_username\"" "$meta_file"; then
      ok "User '$new_username' already in $target_host/meta.nix extraUsers"
    else
      # Add user to existing extraUsers list
      sed -i "s|extraUsers = \[|extraUsers = [ \"$new_username\"|" "$meta_file"
      ok "Added '$new_username' to $target_host/meta.nix extraUsers"
    fi
  else
    # Add extraUsers field before the closing brace
    sed -i "s|}$|  extraUsers = [ \"$new_username\" ];\n}|" "$meta_file"
    ok "Added extraUsers = [ \"$new_username\" ] to $target_host/meta.nix"
  fi

  # 3. Optional password hash
  echo ""
  read -rp "$(echo -e "${CYAN}Generate a login password hash now? [y/N]${NC}: ")" gen_pass
  if [[ "${gen_pass,,}" == "y" ]]; then
    check_tool mkpasswd
    info "Enter your desired login password:"
    local hash
    hash=$(mkpasswd -m sha-512)
    echo ""
    info "Password hash generated. Add to secrets/personal.yaml under:"
    info "  users/$new_username/password_hash: |"
    echo "    $hash"
    echo ""
    warn "Use 'sops secrets/personal.yaml' to add this value."
  fi

  echo ""
  ok "User '$new_username' added to host '$target_host'!"
  info "Next steps:"
  info "  1. Review changes to hosts/$target_host/meta.nix"
  info "  2. Commit and rebuild"
}

# ── Main ─────────────────────────────────────────────────────────────────────

usage() {
  echo "Usage: $0 <--init|--add>"
  echo ""
  echo "  --init    Set up primary user (fork/fresh install)"
  echo "  --add     Add an additional user to a host"
  echo ""
  echo "Examples:"
  echo "  $0 --init          # Replace primary user for a fresh clone"
  echo "  $0 --add           # Add a second user to a specific host"
}

case "${1:-}" in
  --init) do_init ;;
  --add)  do_add ;;
  -h|--help) usage ;;
  *)
    usage
    exit 1
    ;;
esac
