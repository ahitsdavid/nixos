# SOPS-Nix Configuration
{ config, lib, pkgs, ... }:

let
  # Enable secrets
  hasSystemSecrets = true;
  hasPersonalSecrets = true;
  hasWorkSecrets = false;
  hasTailscaleAuthKey = true;  # Set to false if you don't have Tailscale auth key
in
{
  # Enable SOPS
  sops = {
    # Set default age key file location
    age.keyFile = "/home/davidthach/.config/sops/age/keys.txt";

    # Default sops file for personal secrets
    defaultSopsFile = ../../secrets/personal.yaml;
    
    # Only configure secrets if the files exist (fork-friendly!)
    secrets = lib.mkMerge [
      # System secrets (WiFi, VPN, etc.)
      (lib.mkIf hasSystemSecrets {
        # WiFi passwords
        "wifi/dantat" = {
          sopsFile = ../../secrets/system.yaml;
          owner = "root";
          group = "networkmanager";
          mode = "0440";
        };
        "wifi/dantat_5g" = {
          sopsFile = ../../secrets/system.yaml;
          owner = "root";
          group = "networkmanager";
          mode = "0440";
        };
      })

      # Tailscale secrets (separate so forks can disable)
      (lib.mkIf (hasSystemSecrets && hasTailscaleAuthKey) {
        "tailscale/auth_key" = {
          sopsFile = ../../secrets/system.yaml;
          owner = "root";
          mode = "0400";
        };
      })
      
      # Personal secrets (API keys, tokens)
      (lib.mkIf hasPersonalSecrets {
        "api_keys/weather" = {
          # sopsFile defaults to defaultSopsFile
          owner = "davidthach";
          mode = "0400";
        };
        "api_keys/github" = {
          # sopsFile defaults to defaultSopsFile
          owner = "davidthach";
          mode = "0400";
        };
        "api_keys/ai_service" = {
          # sopsFile defaults to defaultSopsFile
          owner = "davidthach";
          mode = "0400";
        };

        # SSH keys for personal servers
        "ssh/unraid_private_key" = {
          # sopsFile defaults to defaultSopsFile
          owner = "davidthach";
          mode = "0400";
          path = "/home/davidthach/.ssh/unraid_rsa";
        };

        # GitHub SSH key
        "ssh/github_private_key" = {
          # sopsFile defaults to defaultSopsFile
          owner = "davidthach";
          mode = "0400";
          path = "/home/davidthach/.ssh/id_rsa";
        };

        # Bitwarden account info (login IDs, NOT passwords)
        "bitwarden/email" = {
          # sopsFile defaults to defaultSopsFile
          owner = "davidthach";
          mode = "0400";
        };
        "bitwarden/self_hosted_url" = {
          # sopsFile defaults to defaultSopsFile
          owner = "davidthach";
          mode = "0400";
        };
        "bitwarden/client_id" = {
          # sopsFile defaults to defaultSopsFile
          owner = "davidthach";
          mode = "0400";
        };
        "bitwarden/client_secret" = {
          # sopsFile defaults to defaultSopsFile
          owner = "davidthach";
          mode = "0400";
        };
      })
      
      # Work secrets  
      (lib.mkIf hasWorkSecrets {
        "work/company_api" = {
          sopsFile = ../../secrets/work.yaml;
          owner = "davidthach";
          mode = "0400";
        };
        "work/vpn_config" = {
          sopsFile = ../../secrets/work.yaml;
          owner = "root";
          mode = "0600";
        };
      })
    ];
  };

  # Make sops command available for users
  environment.systemPackages = with pkgs; [
    sops
    age
  ];
  
  # Create helpful aliases for secret management
  programs.bash.shellAliases = {
    sops-edit-system = "sops secrets/system.yaml";
    sops-edit-personal = "sops secrets/personal.yaml"; 
    sops-edit-work = "sops secrets/work.yaml";
  };
}