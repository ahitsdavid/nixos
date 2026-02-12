# profile/base/nix-config.nix
{ inputs, username }:
{ config, pkgs, lib, ... }: {
  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      auto-optimise-store = true;
      trusted-users = [ "root" "@wheel" ];
      # Increase download buffer for large updates
      download-buffer-size = 268435456; # 256 MiB (in bytes)
      # Binary cache for faster builds
      # Note: VM Harmonia cache (vm:5000) disabled until VM is set up
      # To enable: add "http://vm:5000" to substituters and configure trusted-public-keys
      substituters = [
        "https://cache.nixos.org"
        "http://vm:5000"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "vm-cache:w+a4m3Ar0u+zhZ1bThVg4lUq0DSemKd17YUlwPkAnbM="
      ];
      # Fallback to other caches if VM is offline
      fallback = true;
      connect-timeout = 5;  # Seconds before giving up on a cache
    };

    # Registry configuration
    registry = {
      nixpkgs.flake = inputs.nixpkgs;
      home-manager.flake = inputs.home-manager;
    };

    # Garbage collection
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };

    # Use VM as remote builder (disabled on VM itself)
    distributedBuilds = config.networking.hostName != "vm";
    buildMachines = lib.mkIf (config.networking.hostName != "vm") [
      {
        hostName = "vm";  # Use Tailscale hostname
        system = "x86_64-linux";
        maxJobs = 4;
        speedFactor = 2;
        supportedFeatures = [ "nixos-test" "big-parallel" "kvm" ];
        mandatoryFeatures = [];
        sshUser = username;
        # sshKey = "/path/to/ssh/key";  # Uncomment and set if needed
      }
    ];
  };
}