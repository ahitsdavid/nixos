# profiles/development/default.nix
{ inputs, username }:
{ config, pkgs, ... }: {
  imports = [
    (import ./languages { inherit inputs; })
    (import ./tools.nix { inherit inputs; })
  ];

  # Common development packages
  environment.systemPackages = with pkgs; [
    docker-compose
    insomnia
    git-lfs
    meld
  ];

  # Allow unfree packages moved to flake.nix to avoid home-manager warning
}