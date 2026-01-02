# SOPS-Nix Configuration
{ config, lib, pkgs, ... }:

let
  # Automatically detect which secret files exist (fork-friendly!)
  systemSecretsPath = ../../secrets/system.yaml;
  personalSecretsPath = ../../secrets/personal.yaml;
  workSecretsPath = ../../secrets/work.yaml;

  hasSystemSecrets = builtins.pathExists systemSecretsPath;
  hasPersonalSecrets = builtins.pathExists personalSecretsPath;
  hasWorkSecrets = builtins.pathExists workSecretsPath;
in
{
  # Enable SOPS only if we have at least one secrets file
  sops = lib.mkIf (hasSystemSecrets || hasPersonalSecrets || hasWorkSecrets) {
    # Set default age key file location
    age.keyFile = "/home/davidthach/.config/sops/age/keys.txt";

    # Default sops file for personal secrets (if it exists)
    defaultSopsFile = lib.mkIf hasPersonalSecrets personalSecretsPath;
    
    # Only configure secrets if the files exist (fork-friendly!)
    secrets = lib.mkMerge [
      # System secrets (WiFi, VPN, etc.)
      (lib.mkIf hasSystemSecrets {
        # WiFi passwords
        "wifi/dantat" = {
          sopsFile = systemSecretsPath;
          owner = "root";
          group = "networkmanager";
          mode = "0440";
        };
        "wifi/dantat_5g" = {
          sopsFile = systemSecretsPath;
          owner = "root";
          group = "networkmanager";
          mode = "0440";
        };
      })

      # Tailscale secrets
      (lib.mkIf hasSystemSecrets {
        "tailscale/auth_key" = {
          sopsFile = systemSecretsPath;
          owner = "root";
          mode = "0400";
        };
      })
      
      # Personal secrets (API keys, tokens)
      (lib.mkIf hasPersonalSecrets {
        # User password hash for declarative user management
        "users/davidthach/password_hash" = {
          # sopsFile defaults to defaultSopsFile (personal.yaml)
          neededForUsers = true;  # Available during early boot for user creation
        };

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
          sopsFile = workSecretsPath;
          owner = "davidthach";
          mode = "0400";
        };
        "work/vpn_config" = {
          sopsFile = workSecretsPath;
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