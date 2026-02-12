# Example SOPS-Nix Usage
# This file shows how to use SOPS secrets in your NixOS configuration
# Copy relevant parts to your actual config files as needed

# Note: In real configs, 'username' comes from specialArgs (set in flake.nix)
{ config, lib, pkgs, username ? "youruser", ... }:

{
  # Example: WiFi networks using SOPS secrets
  # Only configure if secrets exist (fork-friendly!)
  networking.wireless = lib.mkIf (config.sops.secrets ? "wifi/home_network") {
    enable = true;
    networks = {
      "YourHomeNetwork" = {
        pskFile = config.sops.secrets."wifi/home_network".path;
      };
      "YourWorkNetwork" = lib.mkIf (config.sops.secrets ? "wifi/work_network") {
        pskFile = config.sops.secrets."wifi/work_network".path;
      };
    };
  };

  # Example: VPN configuration using secrets
  services.openvpn.servers = lib.mkIf (config.sops.secrets ? "vpn/work_config") {
    work = {
      config = config.sops.secrets."vpn/work_config".path;
      autoStart = false;  # Manual start for security
    };
  };

  # Example: Backup service using SSH key from secrets
  systemd.services.backup = lib.mkIf (config.sops.secrets ? "ssh/backup_key") {
    description = "Automated backup service";
    serviceConfig = {
      Type = "oneshot";
      User = "root";
    };
    script = ''
      ${pkgs.rsync}/bin/rsync -avz -e "${pkgs.openssh}/bin/ssh -i ${config.sops.secrets."ssh/backup_key".path}" \
        /home/ backup@backup-server:/backups/$(hostname)/
    '';
    # Run daily
    startAt = "daily";
  };

  # Example: Environment variables for user services (API keys)
  # These would be used by your quickshell widgets
  systemd.user.services.weather-widget = lib.mkIf (config.sops.secrets ? "api_keys/weather") {
    description = "Weather data fetcher for quickshell";
    serviceConfig = {
      Type = "oneshot";
      User = username;
    };
    script = ''
      export WEATHER_API_KEY=$(cat ${config.sops.secrets."api_keys/weather".path})
      # Your weather script here
      ${pkgs.curl}/bin/curl "http://api.openweathermap.org/data/2.5/weather?q=YourCity&appid=$WEATHER_API_KEY"
    '';
    startAt = "hourly";
  };

  # Example: GitHub CLI authentication using personal token
  home-manager.users.${username} = lib.mkIf (config.sops.secrets ? "api_keys/github") {
    programs.gh = {
      enable = true;
      settings = {
        # Don't put the token directly here, use a script instead
        git_protocol = "ssh";
      };
    };
    
    # Script that authenticates using the secret token
    home.packages = [
      (pkgs.writeShellScriptBin "gh-auth-sops" ''
        export GITHUB_TOKEN=$(cat ${config.sops.secrets."api_keys/github".path})
        ${pkgs.gh}/bin/gh auth login --with-token <<< "$GITHUB_TOKEN"
      '')
    ];
  };

  # Example: Custom quickshell script with AI API key
  environment.systemPackages = lib.mkIf (config.sops.secrets ? "api_keys/ai_service") [
    (pkgs.writeShellScriptBin "quickshell-ai" ''
      #!/bin/bash
      # Your quickshell AI integration script
      API_KEY=$(cat ${config.sops.secrets."api_keys/ai_service".path})
      
      # Example: Call OpenAI API or similar
      ${pkgs.curl}/bin/curl -H "Authorization: Bearer $API_KEY" \
        -H "Content-Type: application/json" \
        -d '{"model": "gpt-3.5-turbo", "messages": [{"role": "user", "content": "'"$1"'"}]}' \
        https://api.openai.com/v1/chat/completions
    '')
  ];
}