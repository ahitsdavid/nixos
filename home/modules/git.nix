{ config, pkgs, lib, username, osConfig ? {}, ... }:

let
  # Check if GitLab work secrets exist (fork-friendly)
  # Use osConfig to access NixOS-level sops.secrets from home-manager
  hasGitlabSecrets = (lib.hasAttr "work/gitlab/token" (osConfig.sops.secrets or {}));
in
{
  programs.git = {
    enable = true;

    # Use work email from sops when cloning from work GitLab
    # Personal commits will use this as default (can override per-repo)
    extraConfig = lib.mkMerge [
      # Global git settings
      {
        init.defaultBranch = "main";
        pull.rebase = false;
        push.autoSetupRemote = true;
      }

      # Work GitLab credential helper (only if secrets exist)
      (lib.mkIf hasGitlabSecrets {
        credential = {
          helper = "${config.home.homeDirectory}/.local/bin/git-credential-work-gitlab";
          useHttpPath = true;
        };
      })
    ];
  };

  # Create credential helper and identity scripts
  home.file = lib.mkIf hasGitlabSecrets {
    ".local/bin/git-credential-work-gitlab" = {
      executable = true;
      text = ''
        #!/bin/sh
        # Git credential helper for work GitLab instances
        # Reads credentials from SOPS secrets

        GITLAB_HOST=$(cat /run/secrets/work/gitlab/host 2>/dev/null | sed 's|https://||' | sed 's|/$||')
        GITLAB_USERNAME=$(cat /run/secrets/work/gitlab/username 2>/dev/null)
        GITLAB_TOKEN=$(cat /run/secrets/work/gitlab/token 2>/dev/null)

        # Additional hosts that share the same credentials (read from sops)
        ADDITIONAL_HOSTS=$(cat /run/secrets/work/gitlab/additional-hosts 2>/dev/null)

        # Only respond to "get" requests
        if [ "$1" != "get" ]; then
          exit 0
        fi

        # Read the request from stdin
        host=""
        protocol=""
        while IFS='=' read -r key value; do
          case "$key" in
            host) host="$value" ;;
            protocol) protocol="$value" ;;
          esac
        done

        # Check if host matches primary GitLab host or additional hosts
        is_work_host=false
        if [ "$host" = "$GITLAB_HOST" ]; then
          is_work_host=true
        fi
        for h in $ADDITIONAL_HOSTS; do
          if [ "$host" = "$h" ]; then
            is_work_host=true
            break
          fi
        done

        # Provide credentials for work GitLab hosts
        if [ "$is_work_host" = "true" ]; then
          echo "protocol=$protocol"
          echo "host=$host"
          echo "username=$GITLAB_USERNAME"
          echo "password=$GITLAB_TOKEN"
        fi
      '';
    };

    ".local/bin/git-work-identity" = {
      executable = true;
      text = ''
        #!/bin/sh
        # Configure current repo to use work identity
        WORK_EMAIL=$(cat /run/secrets/work/gitlab/email 2>/dev/null)
        WORK_USERNAME=$(cat /run/secrets/work/gitlab/username 2>/dev/null)

        if [ -z "$WORK_EMAIL" ] || [ -z "$WORK_USERNAME" ]; then
          echo "Error: Work secrets not available"
          exit 1
        fi

        git config user.email "$WORK_EMAIL"
        git config user.name "$WORK_USERNAME"
        echo "Configured repo to use work identity:"
        echo "  Email: $WORK_EMAIL"
        echo "  Name: $WORK_USERNAME"
      '';
    };
  };
}
