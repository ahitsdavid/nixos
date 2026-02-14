{ config, lib, pkgs, username, ... }:

let
  # Check if SSH secrets exist (fork-friendly)
  hasUnraidKey = (lib.hasAttr "ssh/unraid_private_key" (config.sops.secrets or {}));
  hasGithubKey = (lib.hasAttr "ssh/github_private_key" (config.sops.secrets or {}));

  # Import central Tailscale hosts definition
  tailscaleHosts = import ./tailscale-hosts.nix;

  # Generate SSH matchBlocks for each Tailscale host
  tailscaleMatchBlocks = lib.mapAttrs (name: opts: {
    hostname = name;  # Tailscale MagicDNS resolves this
    user = username;
    extraOptions = {
      "StrictHostKeyChecking" = "accept-new";
    };
  }) tailscaleHosts;
in
{
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;

    # SSH client configuration
    matchBlocks = lib.mkMerge [
      # All Tailscale hosts
      tailscaleMatchBlocks

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

}
