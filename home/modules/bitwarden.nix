{ config, pkgs, lib, username, ... }:

{
  # Only enable for davidthach user
  home.packages = lib.mkIf (username == "davidthach") (with pkgs; [
    bitwarden-cli
  ]);

  # Create wrapper scripts that read credentials from SOPS secrets
  home.file = lib.mkIf (username == "davidthach") {
    ".local/bin/bw-self" = {
      executable = true;
      text = ''
        #!/bin/sh
        BW_URL=$(cat /run/secrets/bitwarden/self_hosted_url)
        export BW_CLIENTID=$(cat /run/secrets/bitwarden/client_id)
        export BW_CLIENTSECRET=$(cat /run/secrets/bitwarden/client_secret)

        # Logout if already logged in
        bw logout 2>/dev/null || true

        bw config server "$BW_URL"
        echo "Logging in with API key..."
        bw login --apikey
      '';
    };
    ".local/bin/bw-standard" = {
      executable = true;
      text = ''
        #!/bin/sh
        BW_EMAIL=$(cat /run/secrets/bitwarden/email)
        bw config server https://vault.bitwarden.com && bw login "$BW_EMAIL"
      '';
    };
  };

  # Shell aliases for managing multiple Bitwarden accounts
  programs.zsh.shellAliases = lib.mkIf (username == "davidthach") {
    # Wrapper scripts (read from SOPS secrets)
    bw-self = "~/.local/bin/bw-self";
    bw-standard = "~/.local/bin/bw-standard";

    # Common commands
    bw-unlock = "bw unlock";
    bw-lock = "bw lock";
    bw-sync = "bw sync";
    bw-get = "bw get";
  };

  # Environment setup
  home.sessionVariables = lib.mkIf (username == "davidthach") {
    # Bitwarden CLI uses these
    BW_SESSION = "";  # Will be set after unlock
  };
}
