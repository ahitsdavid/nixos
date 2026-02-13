#!/usr/bin/env bash
# deploy.sh — Deploy NixOS configuration to a host
#
# Usage:
#   scripts/deploy.sh [options] <hostname>
#
# Options:
#   --build-only    Build but don't activate (nix build only)
#   --dry-run       Show what would be built without building
#   --skip-checks   Skip pre-deploy validation
#   --target-host   Deploy to remote host via SSH (default: deploy locally)
#   --boot          Use 'boot' instead of 'switch' (activate on next reboot)
#   -h, --help      Show usage
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

# Get username from flake.nix
get_username() {
  grep -oP 'username = "\K[^"]+' "$REPO_ROOT/flake.nix"
}

# ── Host discovery ───────────────────────────────────────────────────────────

get_all_hosts() {
  local hosts=()
  for d in "$REPO_ROOT"/hosts/*/; do
    [[ -d "$d" ]] && hosts+=("$(basename "$d")")
  done
  echo "${hosts[@]}"
}

read_host_meta() {
  local hostname="$1"
  local meta_file="$REPO_ROOT/hosts/$hostname/meta.nix"

  HOST_DESC=""
  HOST_SSH_ALIAS=""
  HOST_IS_HEADLESS="false"

  if [[ -f "$meta_file" ]]; then
    HOST_DESC=$(grep -oP 'description\s*=\s*"\K[^"]+' "$meta_file" 2>/dev/null || echo "")
    HOST_SSH_ALIAS=$(grep -oP 'sshAlias\s*=\s*"\K[^"]+' "$meta_file" 2>/dev/null || echo "")
    HOST_IS_HEADLESS=$(grep -oP 'isHeadless\s*=\s*\K(true|false)' "$meta_file" 2>/dev/null || echo "false")
  fi
}

# ── Pre-deploy checks ───────────────────────────────────────────────────────

pre_deploy_checks() {
  local hostname="$1"
  local remote="${2:-}"
  local pass=true

  info "Running pre-deploy checks..."
  echo ""

  # 1. Validate hostname exists
  if [[ ! -d "$REPO_ROOT/hosts/$hostname" ]]; then
    err "Host directory 'hosts/$hostname' not found."
    echo ""
    info "Available hosts:"
    for h in $(get_all_hosts); do
      echo "  - $h"
    done
    exit 1
  fi
  ok "Host '$hostname' exists"

  # 2. Git status check
  local git_status
  git_status=$(git -C "$REPO_ROOT" status --porcelain 2>/dev/null || true)
  if [[ -n "$git_status" ]]; then
    warn "Uncommitted changes detected:"
    echo "$git_status" | head -10 | while IFS= read -r line; do
      echo "    $line"
    done
    local total
    total=$(echo "$git_status" | wc -l)
    if [[ $total -gt 10 ]]; then
      echo "    ... and $((total - 10)) more"
    fi
    warn "The deployed config may not match your working tree."
    echo ""
  else
    ok "Working tree is clean"
  fi

  # 3. Remote connectivity check
  if [[ -n "$remote" ]]; then
    local username
    username=$(get_username)
    info "Testing SSH connectivity to $hostname..."
    if ssh -o ConnectTimeout=5 -o BatchMode=yes "$username@$hostname" true 2>/dev/null; then
      ok "SSH connection to $hostname successful"
    else
      err "Cannot reach $hostname via SSH"
      info "Make sure Tailscale is running and the host is online."
      pass=false
    fi
  fi

  echo ""
  if [[ "$pass" == "false" ]]; then
    err "Pre-deploy checks failed."
    exit 1
  fi
  ok "All checks passed"
}

# ── Deploy ───────────────────────────────────────────────────────────────────

do_deploy() {
  local hostname="$1"
  local action="$2"      # switch|boot|build-only|dry-run
  local remote="$3"      # "" for local, "true" for remote

  local start_time
  start_time=$(date +%s)

  echo ""
  echo -e "${GREEN}──────────────────────────────────────────────────────────────${NC}"
  echo -e "${GREEN}  Deployment Summary${NC}"
  echo -e "${GREEN}──────────────────────────────────────────────────────────────${NC}"
  echo ""
  info "  Host:     $hostname${HOST_DESC:+ ($HOST_DESC)}"
  info "  Action:   $action"
  if [[ -n "$remote" ]]; then
    info "  Target:   remote (via SSH)"
  else
    info "  Target:   local"
  fi
  echo ""

  local username
  username=$(get_username)

  case "$action" in
    dry-run)
      info "Dry-run: showing what would be built..."
      echo ""
      nixos-rebuild dry-activate --flake "$REPO_ROOT#$hostname"
      ;;

    build-only)
      info "Building system closure (no activation)..."
      echo ""
      nix build "$REPO_ROOT#nixosConfigurations.$hostname.config.system.build.toplevel" \
        --print-build-logs
      ok "Build completed. Result in ./result"
      ;;

    switch|boot)
      if [[ -n "$remote" ]]; then
        info "Deploying to remote host $hostname..."
        echo ""
        nixos-rebuild "$action" --flake "$REPO_ROOT#$hostname" \
          --target-host "$username@$hostname" \
          --use-remote-sudo \
          --print-build-logs
      else
        info "Deploying locally..."
        echo ""
        sudo nixos-rebuild "$action" --flake "$REPO_ROOT#$hostname" \
          --print-build-logs
      fi
      ;;
  esac

  local end_time elapsed
  end_time=$(date +%s)
  elapsed=$((end_time - start_time))

  echo ""
  echo -e "${GREEN}══════════════════════════════════════════════════════════════${NC}"
  ok "Deployment completed in ${elapsed}s"
  echo -e "${GREEN}══════════════════════════════════════════════════════════════${NC}"

  if [[ "$action" == "boot" ]]; then
    echo ""
    info "Changes will take effect on next reboot."
  fi
}

# ── Argument parsing ─────────────────────────────────────────────────────────

usage() {
  echo "Usage: $0 [options] <hostname>"
  echo ""
  echo "Deploy NixOS configuration to a host."
  echo ""
  echo "Options:"
  echo "  --build-only    Build but don't activate"
  echo "  --dry-run       Show what would be built without building"
  echo "  --skip-checks   Skip pre-deploy validation"
  echo "  --target-host   Deploy to remote host via SSH"
  echo "  --boot          Use 'boot' instead of 'switch' (activate on reboot)"
  echo "  -h, --help      Show this help message"
  echo ""
  echo "Examples:"
  echo "  $0 desktop                     # Deploy locally to desktop"
  echo "  $0 --target-host thinkpad      # Deploy to thinkpad via SSH"
  echo "  $0 --dry-run desktop           # Show what would change"
  echo "  $0 --build-only desktop        # Build without activating"
  echo "  $0 --boot --target-host vm     # Deploy to VM, activate on reboot"
  echo ""
  echo "Available hosts:"
  for d in "$REPO_ROOT"/hosts/*/; do
    [[ -d "$d" ]] || continue
    local hname hdesc
    hname=$(basename "$d")
    hdesc=$(grep -oP 'description\s*=\s*"\K[^"]+' "$d/meta.nix" 2>/dev/null || echo "")
    echo "  - $hname${hdesc:+ ($hdesc)}"
  done
}

main() {
  local action="switch"
  local remote=""
  local skip_checks=false
  local hostname=""

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --build-only)    action="build-only"; shift ;;
      --dry-run)       action="dry-run"; shift ;;
      --skip-checks)   skip_checks=true; shift ;;
      --target-host)   remote="true"; shift ;;
      --boot)          action="boot"; shift ;;
      -h|--help)       usage; exit 0 ;;
      -*)              err "Unknown option: $1"; echo ""; usage; exit 1 ;;
      *)               hostname="$1"; shift ;;
    esac
  done

  # If no hostname provided, show hosts and prompt
  if [[ -z "$hostname" ]]; then
    echo ""
    info "No hostname specified."
    echo ""
    info "Available hosts:"
    for d in "$REPO_ROOT"/hosts/*/; do
      [[ -d "$d" ]] || continue
      local hname hdesc
      hname=$(basename "$d")
      hdesc=$(grep -oP 'description\s*=\s*"\K[^"]+' "$d/meta.nix" 2>/dev/null || echo "")
      echo "  - $hname${hdesc:+ ($hdesc)}"
    done
    echo ""
    read -rp "$(echo -e "${CYAN}Hostname${NC}: ")" hostname
    if [[ -z "$hostname" ]]; then
      err "No hostname provided."
      exit 1
    fi
  fi

  # Read host metadata
  read_host_meta "$hostname"

  # Pre-deploy checks
  if [[ "$skip_checks" != "true" ]]; then
    echo ""
    pre_deploy_checks "$hostname" "$remote"
  fi

  # Deploy
  do_deploy "$hostname" "$action" "$remote"
}

main "$@"
