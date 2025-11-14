# profile/base/nix-config.nix
{ inputs }:
{ config, pkgs, ... }: {
  nix = {
    # Enable flakes (necessary for new systems)
    #package = pkgs.nixFlakes;
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      auto-optimise-store = true;
      trusted-users = [ "root" "@wheel" ];
      # Increase download buffer for large updates
      download-buffer-size = 268435456; # 256 MiB (in bytes)
      # Binary cache for faster builds
      substituters = [
        "https://cache.nixos.org"
        ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        ];
      };
  
    #Registry configuraiton
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
  };
}