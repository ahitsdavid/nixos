#!/usr/bin/env bash
# setup-secrets.sh — SOPS secrets bootstrap and management
#
# Usage:
#   scripts/setup-secrets.sh <command>
#
# Commands:
#   bootstrap     Full interactive SOPS setup wizard
#   keygen        Generate a new age key for the current user
#   system-key    Copy age key to /var/lib/sops-nix/key.txt (for system services)
#   reencrypt     Re-encrypt all secrets with current .sops.yaml keys
#   verify        Verify all secrets can be decrypted with current key
#   rotate        Generate new key, update .sops.yaml, re-encrypt all secrets
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

# ── Key helpers ──────────────────────────────────────────────────────────────

get_age_key_path() {
  echo "$HOME/.config/sops/age/keys.txt"
}

get_public_key() {
  local keyfile="$1"
  grep "public key:" "$keyfile" | awk '{print $NF}'
}

get_secret_files() {
  local files=()
  for f in "$REPO_ROOT"/secrets/*.yaml; do
    [[ -f "$f" ]] || continue
    # Skip example files
    [[ "$f" == *.example ]] && continue
    files+=("$f")
  done
  echo "${files[@]}"
}

# ── Commands ─────────────────────────────────────────────────────────────────

cmd_keygen() {
  local keyfile
  keyfile="$(get_age_key_path)"

  echo ""
  info "Age key path: $keyfile"

  if [[ -f "$keyfile" ]]; then
    local pubkey
    pubkey=$(get_public_key "$keyfile")
    ok "Age key already exists"
    info "Public key: $pubkey"
    echo ""

    prompt_yn "Overwrite with a new key?" "n" overwrite
    if [[ "$overwrite" != "true" ]]; then
      info "Keeping existing key."
      return
    fi

    # Backup existing key
    cp "$keyfile" "${keyfile}.bak"
    ok "Backed up existing key to ${keyfile}.bak"
  fi

  check_tool age-keygen

  mkdir -p "$(dirname "$keyfile")"
  age-keygen -o "$keyfile" 2>&1
  chmod 600 "$keyfile"
  ok "Age key generated at $keyfile"

  local pubkey
  pubkey=$(get_public_key "$keyfile")
  info "Public key: $pubkey"
}

cmd_system_key() {
  local keyfile
  keyfile="$(get_age_key_path)"

  echo ""
  if [[ ! -f "$keyfile" ]]; then
    err "No age key found at $keyfile"
    info "Run 'setup-secrets.sh keygen' first."
    exit 1
  fi

  local pubkey
  pubkey=$(get_public_key "$keyfile")
  info "Will copy age key to /var/lib/sops-nix/key.txt"
  info "Public key: $pubkey"
  echo ""
  warn "This requires sudo access."
  echo ""

  prompt_yn "Proceed?" "y" proceed
  if [[ "$proceed" != "true" ]]; then
    info "Aborted."
    return
  fi

  sudo mkdir -p /var/lib/sops-nix
  sudo cp "$keyfile" /var/lib/sops-nix/key.txt
  sudo chmod 600 /var/lib/sops-nix/key.txt
  ok "Copied age key to /var/lib/sops-nix/key.txt"
  info "System services (sops-nix) can now decrypt secrets at boot."
}

cmd_reencrypt() {
  check_tool sops

  echo ""
  info "Re-encrypting secrets with current .sops.yaml keys..."
  echo ""

  local files
  files=$(get_secret_files)
  if [[ -z "$files" ]]; then
    warn "No secret files found in secrets/"
    return
  fi

  local success=0 fail=0
  for f in $files; do
    local fname
    fname=$(basename "$f")
    if sops updatekeys -y "$f" 2>/dev/null; then
      ok "  $fname"
      ((success++))
    else
      err "  $fname — failed to re-encrypt"
      ((fail++))
    fi
  done

  echo ""
  if [[ $fail -eq 0 ]]; then
    ok "All $success file(s) re-encrypted successfully."
  else
    warn "$success succeeded, $fail failed."
  fi
}

cmd_verify() {
  local keyfile
  keyfile="$(get_age_key_path)"

  echo ""
  if [[ ! -f "$keyfile" ]]; then
    err "No age key found at $keyfile"
    info "Run 'setup-secrets.sh keygen' first."
    exit 1
  fi

  local pubkey
  pubkey=$(get_public_key "$keyfile")
  info "Verifying secrets with key: $pubkey"
  echo ""

  local files
  files=$(get_secret_files)
  if [[ -z "$files" ]]; then
    warn "No secret files found in secrets/"
    return
  fi

  local success=0 fail=0 total=0
  for f in $files; do
    local fname
    fname=$(basename "$f")
    ((total++))
    if sops --decrypt "$f" > /dev/null 2>&1; then
      ok "  $fname — decryptable"
      ((success++))
    else
      err "  $fname — cannot decrypt"
      ((fail++))
    fi
  done

  echo ""
  if [[ $fail -eq 0 ]]; then
    ok "All $total file(s) verified successfully."
  else
    warn "$success/$total files verified. $fail file(s) cannot be decrypted."
    info "Re-encrypt with: setup-secrets.sh reencrypt"
  fi
}

cmd_rotate() {
  echo ""
  echo -e "${GREEN}══════════════════════════════════════════════════════════════${NC}"
  echo -e "${GREEN}  SOPS Key Rotation${NC}"
  echo -e "${GREEN}══════════════════════════════════════════════════════════════${NC}"
  echo ""
  warn "This will:"
  warn "  1. Backup your current age key"
  warn "  2. Generate a new age key"
  warn "  3. Update .sops.yaml &daily anchor with the new public key"
  warn "  4. Re-encrypt all secrets with the new key"
  echo ""

  prompt_yn "Proceed with key rotation?" "n" proceed
  if [[ "$proceed" != "true" ]]; then
    info "Aborted."
    return
  fi

  local keyfile
  keyfile="$(get_age_key_path)"

  # Step 1: Backup existing key
  if [[ -f "$keyfile" ]]; then
    cp "$keyfile" "${keyfile}.bak"
    ok "Backed up existing key to ${keyfile}.bak"
  fi

  # Step 2: Generate new key
  check_tool age-keygen
  mkdir -p "$(dirname "$keyfile")"
  age-keygen -o "$keyfile" 2>&1
  chmod 600 "$keyfile"
  ok "New age key generated"

  local pubkey
  pubkey=$(get_public_key "$keyfile")
  info "New public key: $pubkey"

  # Step 3: Update .sops.yaml
  local sops_yaml="$REPO_ROOT/.sops.yaml"
  if [[ -f "$sops_yaml" ]]; then
    local old_key
    old_key=$(grep '&daily' "$sops_yaml" | sed 's/.*&daily //')
    if [[ -n "$old_key" ]]; then
      sed -i "s|$old_key|$pubkey|" "$sops_yaml"
      ok "Updated .sops.yaml &daily key"
    else
      warn "Could not find &daily anchor in .sops.yaml — update manually."
    fi
  else
    warn ".sops.yaml not found — update manually."
  fi

  # Step 4: Re-encrypt all secrets
  echo ""
  cmd_reencrypt

  echo ""
  ok "Key rotation complete!"
  info "Next steps:"
  info "  1. Commit changes: git add .sops.yaml secrets/ && git commit -m 'Rotate SOPS age key'"
  info "  2. Deploy to all hosts to update their key copies"
  info "  3. If you use system-key, re-run: setup-secrets.sh system-key"
}

cmd_bootstrap() {
  echo ""
  echo -e "${GREEN}══════════════════════════════════════════════════════════════${NC}"
  echo -e "${GREEN}  SOPS Secrets — Bootstrap Wizard${NC}"
  echo -e "${GREEN}══════════════════════════════════════════════════════════════${NC}"
  echo ""
  info "This wizard will set up SOPS-nix secrets management for your system."
  info "It will generate an age encryption key and configure .sops.yaml."
  echo ""

  # Step 1: Check required tools
  info "Checking required tools..."
  check_tool age-keygen
  check_tool sops
  ok "All tools available."
  echo ""

  # Step 2: Generate age key
  info "Step 1: Age encryption key"
  cmd_keygen

  # Step 3: Update .sops.yaml
  echo ""
  info "Step 2: Configure .sops.yaml"
  local keyfile
  keyfile="$(get_age_key_path)"
  local pubkey
  pubkey=$(get_public_key "$keyfile")

  local sops_yaml="$REPO_ROOT/.sops.yaml"
  if [[ -f "$sops_yaml" ]]; then
    local current_daily
    current_daily=$(grep '&daily' "$sops_yaml" | sed 's/.*&daily //')
    info "Current &daily key in .sops.yaml:"
    info "  $current_daily"
    info "Your public key:"
    info "  $pubkey"

    if [[ "$current_daily" == "$pubkey" ]]; then
      ok ".sops.yaml already has your key."
    else
      echo ""
      prompt_yn "Update &daily anchor with your public key?" "y" update_sops
      if [[ "$update_sops" == "true" ]]; then
        sed -i "s|$current_daily|$pubkey|" "$sops_yaml"
        ok "Updated .sops.yaml &daily key"
      fi
    fi
  else
    warn ".sops.yaml not found — you'll need to create it manually."
  fi

  # Step 4: Create example secrets
  echo ""
  info "Step 3: Secret files"
  local created_any=false
  for example in "$REPO_ROOT"/secrets/*.yaml.example; do
    [[ -f "$example" ]] || continue
    local target="${example%.example}"
    local fname
    fname=$(basename "$target")
    if [[ -f "$target" ]]; then
      ok "  $fname already exists"
    else
      prompt_yn "  Create $fname from template?" "y" create_it
      if [[ "$create_it" == "true" ]]; then
        cp "$example" "$target"
        info "  Encrypting $fname with sops..."
        if sops --encrypt --in-place "$target" 2>/dev/null; then
          ok "  Created and encrypted $fname"
          created_any=true
        else
          warn "  Created $fname but encryption failed — edit with: sops $target"
          created_any=true
        fi
      fi
    fi
  done

  # Step 5: Verify
  echo ""
  info "Step 4: Verification"
  cmd_verify

  # Done
  echo ""
  echo -e "${GREEN}══════════════════════════════════════════════════════════════${NC}"
  ok "Bootstrap complete!"
  echo -e "${GREEN}══════════════════════════════════════════════════════════════${NC}"
  echo ""
  info "Next steps:"
  info "  1. Edit secrets: sops secrets/personal.yaml"
  info "  2. Commit: git add .sops.yaml secrets/ && git commit -m 'Bootstrap SOPS secrets'"
  info "  3. Rebuild: nixos-rebuild switch --flake .#\$(hostname)"
  echo ""
  info "Useful aliases (available after rebuild):"
  info "  sops-edit-system    — Edit system secrets"
  info "  sops-edit-personal  — Edit personal secrets"
  info "  sops-edit-work      — Edit work secrets"
}

# ── Entry point ──────────────────────────────────────────────────────────────

usage() {
  echo "Usage: $0 <command>"
  echo ""
  echo "SOPS secrets bootstrap and management."
  echo ""
  echo "Commands:"
  echo "  bootstrap     Full interactive SOPS setup wizard"
  echo "  keygen        Generate a new age key for the current user"
  echo "  system-key    Copy age key to /var/lib/sops-nix/key.txt"
  echo "  reencrypt     Re-encrypt all secrets with current .sops.yaml keys"
  echo "  verify        Verify all secrets can be decrypted with current key"
  echo "  rotate        Generate new key, update .sops.yaml, re-encrypt all"
  echo ""
  echo "Examples:"
  echo "  $0 bootstrap       # First-time setup"
  echo "  $0 verify          # Check all secrets are decryptable"
  echo "  $0 rotate          # Rotate to a new encryption key"
}

case "${1:-}" in
  bootstrap)   cmd_bootstrap ;;
  keygen)      cmd_keygen ;;
  system-key)  cmd_system_key ;;
  reencrypt)   cmd_reencrypt ;;
  verify)      cmd_verify ;;
  rotate)      cmd_rotate ;;
  -h|--help)   usage ;;
  *)           usage; exit 1 ;;
esac
