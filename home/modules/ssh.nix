{ config, lib, pkgs, ... }:

let
  # Check if SSH secrets exist (fork-friendly)
  hasUnraidKey = (lib.hasAttr "ssh/unraid_private_key" (config.sops.secrets or {}));
  hasGithubKey = (lib.hasAttr "ssh/github_private_key" (config.sops.secrets or {}));
in
{
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;

    # SSH client configuration
    matchBlocks = lib.mkMerge [
      # GitHub SSH access
      (lib.mkIf hasGithubKey {
        "github.com" = {
          hostname = "github.com";
          user = "git";
          identityFile = "${config.home.homeDirectory}/.ssh/id_rsa";
          identitiesOnly = true;
        };
      })

      # Unraid server
      (lib.mkIf hasUnraidKey {
        "unraid" = {
          hostname = "192.168.1.29";
          user = "root";
          identityFile = "${config.home.homeDirectory}/.ssh/unraid_rsa";
          extraOptions = {
            "StrictHostKeyChecking" = "accept-new";
          };
        };
      })
    ];
  };

  # Ensure .ssh directory exists with correct permissions
  home.file.".ssh/.keep" = {
    text = "";
    onChange = ''
      chmod 700 ${config.home.homeDirectory}/.ssh
    '';
  };
}
