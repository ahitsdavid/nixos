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

    # Persist GitHub host keys so git push works after every rebuild
    knownHosts = lib.mkIf hasGithubKey {
      github-rsa = {
        hostNames = [ "github.com" ];
        publicKey = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCj7ndNxQowgcQnjshcLrqPEiiphnt+VTTvDP6mHBL9j1aNUkY4Ue1gvwnGLVlOhGeYrnZaMgRK6+PKCUXaDbC7qtbW8gIkhL7aGCsOr/C56SJMy/BCZfxd1nWzAOxSDPgVsmerOBYfNqltV9/hWCqBywINIR+5dIg6JTJ72pcEpEjcYgXkE2YEFXV1JHnsKgbLWNlhScqb2UmyRkQyytRLtL+38TGxkxCflmO+5Z8CSSNY7GidjMIZ7Q4zMjA2n1nGrlTDkzwDCsw+wqFPGQA179cnfGWOWRVruj16z6XyvxvjJwbz0wQZ75XK5tKSb7FNyeIEs4TT4jk+S4dhPeAUC5y+bDYirYgM4GC7uEnztnZyaVWQ7B381AK4Qdrwt51ZqExKbQpTUNn+EjqoTwvqNj4kqx5QUCI0ThS/YkOxJCXmPUWZbhjpCg56i+2aB6CmK2JGhn57K5mj0MNdBXA4/WnwH6XoPWJzK5Nyu2zB3nAZp+S5hpQs+p1vN1/wsjk=";
      };
      github-ed25519 = {
        hostNames = [ "github.com" ];
        publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl";
      };
    };
  };

}
