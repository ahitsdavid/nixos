{ pkgs, ... }:

let
  sops-manager = pkgs.writeShellScriptBin "sops-manager" ''
    #!/usr/bin/env bash
    set -euo pipefail

    SECRETS_DIR="$HOME/nixos/secrets"

    # Colors via gum
    export GUM_CHOOSE_CURSOR_FOREGROUND="212"
    export GUM_CHOOSE_SELECTED_FOREGROUND="212"

    show_help() {
      echo "sops-manager - Manage sops-nix secrets"
      echo ""
      echo "Usage: sops-manager [command]"
      echo ""
      echo "Commands:"
      echo "  (none)    Interactive mode"
      echo "  list      List all secret keys"
      echo "  edit      Edit a secrets file"
      echo "  add       Add a new secret"
      echo "  remove    Remove a secret"
      echo "  help      Show this help"
    }

    select_file() {
      local files=()
      for f in "$SECRETS_DIR"/*.yaml; do
        [[ -f "$f" ]] && [[ ! "$f" =~ \.example$ ]] && files+=("$(basename "$f")")
      done

      if [[ ''${#files[@]} -eq 0 ]]; then
        ${pkgs.gum}/bin/gum style --foreground 196 "No secrets files found in $SECRETS_DIR"
        exit 1
      fi

      printf '%s\n' "''${files[@]}" | ${pkgs.gum}/bin/gum choose --header "Select secrets file:"
    }

    list_secrets() {
      local file
      file=$(select_file)
      [[ -z "$file" ]] && exit 0

      ${pkgs.gum}/bin/gum style --bold --foreground 212 "Keys in $file:"
      ${pkgs.sops}/bin/sops --decrypt "$SECRETS_DIR/$file" 2>/dev/null | ${pkgs.yq-go}/bin/yq -r '.. | path | join(".")' | grep -v '^$' | sort -u
    }

    edit_secrets() {
      local file
      file=$(select_file)
      [[ -z "$file" ]] && exit 0

      ${pkgs.sops}/bin/sops "$SECRETS_DIR/$file"
    }

    add_secret() {
      local file key value

      file=$(select_file)
      [[ -z "$file" ]] && exit 0

      ${pkgs.gum}/bin/gum style --bold "Adding secret to $file"
      echo ""

      key=$(${pkgs.gum}/bin/gum input --placeholder "Secret path (e.g., api_keys.github)")
      [[ -z "$key" ]] && { echo "Cancelled."; exit 0; }

      value=$(${pkgs.gum}/bin/gum input --password --placeholder "Secret value")
      [[ -z "$value" ]] && { echo "Cancelled."; exit 0; }

      # Confirm
      if ${pkgs.gum}/bin/gum confirm "Add '$key' to $file?"; then
        ${pkgs.sops}/bin/sops --decrypt "$SECRETS_DIR/$file" 2>/dev/null | \
          ${pkgs.yq-go}/bin/yq eval ".$key = \"$value\"" - | \
          ${pkgs.sops}/bin/sops --encrypt --input-type yaml --output-type yaml /dev/stdin > "$SECRETS_DIR/$file.tmp"
        mv "$SECRETS_DIR/$file.tmp" "$SECRETS_DIR/$file"
        ${pkgs.gum}/bin/gum style --foreground 82 "✓ Added $key"
      else
        echo "Cancelled."
      fi
    }

    remove_secret() {
      local file key keys

      file=$(select_file)
      [[ -z "$file" ]] && exit 0

      # Get list of keys for selection
      keys=$(${pkgs.sops}/bin/sops --decrypt "$SECRETS_DIR/$file" 2>/dev/null | ${pkgs.yq-go}/bin/yq -r '.. | path | join(".")' | grep -v '^$' | sort -u)

      if [[ -z "$keys" ]]; then
        ${pkgs.gum}/bin/gum style --foreground 196 "No secrets found in $file"
        exit 1
      fi

      key=$(echo "$keys" | ${pkgs.gum}/bin/gum choose --header "Select secret to remove:")
      [[ -z "$key" ]] && exit 0

      # Confirm with warning
      ${pkgs.gum}/bin/gum style --foreground 196 --bold "Warning: This will permanently remove '$key'"

      if ${pkgs.gum}/bin/gum confirm "Remove '$key' from $file?"; then
        ${pkgs.sops}/bin/sops --decrypt "$SECRETS_DIR/$file" 2>/dev/null | \
          ${pkgs.yq-go}/bin/yq eval "del(.$key)" - | \
          ${pkgs.sops}/bin/sops --encrypt --input-type yaml --output-type yaml /dev/stdin > "$SECRETS_DIR/$file.tmp"
        mv "$SECRETS_DIR/$file.tmp" "$SECRETS_DIR/$file"
        ${pkgs.gum}/bin/gum style --foreground 82 "✓ Removed $key"
      else
        echo "Cancelled."
      fi
    }

    interactive_mode() {
      local action
      action=$(${pkgs.gum}/bin/gum choose --header "sops-manager" \
        "List secrets" \
        "Edit file" \
        "Add secret" \
        "Remove secret" \
        "Exit")

      case "$action" in
        "List secrets") list_secrets ;;
        "Edit file") edit_secrets ;;
        "Add secret") add_secret ;;
        "Remove secret") remove_secret ;;
        "Exit") exit 0 ;;
      esac
    }

    # Main
    case "''${1:-}" in
      list) list_secrets ;;
      edit) edit_secrets ;;
      add) add_secret ;;
      remove) remove_secret ;;
      help|--help|-h) show_help ;;
      "") interactive_mode ;;
      *) show_help; exit 1 ;;
    esac
  '';
in
{
  home.packages = [
    sops-manager
    pkgs.gum
    pkgs.yq-go
    pkgs.sops
  ];
}
