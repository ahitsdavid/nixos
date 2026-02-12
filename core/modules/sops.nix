# SOPS-Nix Configuration
#
# This module configures encrypted secrets for NixOS using SOPS + age.
# Secrets are decrypted at activation time and placed in /run/secrets/.
#
# Secret files:
#   - secrets/system.yaml:   Infrastructure (WiFi, Tailscale, Harmonia)
#   - secrets/personal.yaml: User credentials and API keys
#   - secrets/work.yaml:     Work-related credentials
#
# To edit secrets: sops secrets/<file>.yaml
# To add new secrets: Add key to YAML, then configure below
#
{ config, lib, pkgs, username, ... }:

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
    age.keyFile = "/home/${username}/.config/sops/age/keys.txt";

    # Default sops file for personal secrets (if it exists)
    defaultSopsFile = lib.mkIf hasPersonalSecrets personalSecretsPath;

    secrets = lib.mkMerge [
      # ══════════════════════════════════════════════════════════════════
      # SYSTEM SECRETS (system.yaml)
      # Infrastructure and network configuration
      # ══════════════════════════════════════════════════════════════════
      (lib.mkIf hasSystemSecrets {
        # Tailscale VPN authentication key
        # Used by: core/modules/tailscale.nix (authKeyFile)
        # Generate at: https://login.tailscale.com/admin/settings/keys
        "tailscale/auth_key" = {
          sopsFile = systemSecretsPath;
          owner = "root";
          mode = "0400";
        };

        # WiFi passwords for NetworkManager
        # Note: These are available but NetworkManager typically uses its own keyring
        # To use: reference config.sops.secrets."wifi/dantat".path in NM config
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

      # ══════════════════════════════════════════════════════════════════
      # PERSONAL SECRETS (personal.yaml)
      # User credentials, API keys, SSH keys
      # ══════════════════════════════════════════════════════════════════
      (lib.mkIf hasPersonalSecrets {
        # User password hash for declarative user management
        # Used by: profiles/base/users.nix (hashedPasswordFile)
        # Generate with: mkpasswd -m sha-512
        "users/${username}/password_hash" = {
          owner = "root";
          mode = "0400";
        };

        # SSH private keys - deployed directly to ~/.ssh/
        # Used by: SSH client (reads from path automatically)
        "ssh/unraid_private_key" = {
          owner = username;
          mode = "0400";
          path = "/home/${username}/.ssh/unraid_rsa";  # Custom path
        };
        "ssh/github_private_key" = {
          owner = username;
          mode = "0400";
          path = "/home/${username}/.ssh/id_rsa";  # Default SSH key
        };

        # API keys for various services
        # Used by: Scripts, widgets, or CLI tools that read from path
        "api_keys/weather" = {
          owner = username;
          mode = "0400";
        };
        "api_keys/github" = {
          owner = username;
          mode = "0400";
        };
        "api_keys/ai_service" = {
          owner = username;
          mode = "0400";
        };

        # Bitwarden CLI authentication
        # Used by: `bw` CLI tool for password management
        # See: https://bitwarden.com/help/cli/
        "bitwarden/email" = {
          owner = username;
          mode = "0400";
        };
        "bitwarden/self_hosted_url" = {
          owner = username;
          mode = "0400";
        };
        "bitwarden/client_id" = {
          owner = username;
          mode = "0400";
        };
        "bitwarden/client_secret" = {
          owner = username;
          mode = "0400";
        };
      })

      # ══════════════════════════════════════════════════════════════════
      # WORK SECRETS (work.yaml)
      # Employer-related credentials
      # ══════════════════════════════════════════════════════════════════
      (lib.mkIf hasWorkSecrets {
        # GitLab credentials for work repositories
        # Used by: Git CLI, IDE integrations
        "work/gitlab/host" = {
          sopsFile = workSecretsPath;
          owner = username;
          mode = "0400";
        };
        "work/gitlab/additional-hosts" = {
          sopsFile = workSecretsPath;
          owner = username;
          mode = "0400";
        };
        "work/gitlab/token" = {
          sopsFile = workSecretsPath;
          owner = username;
          mode = "0400";
        };
        "work/gitlab/email" = {
          sopsFile = workSecretsPath;
          owner = username;
          mode = "0400";
        };
        "work/gitlab/username" = {
          sopsFile = workSecretsPath;
          owner = username;
          mode = "0400";
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