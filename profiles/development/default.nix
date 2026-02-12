# profiles/development/default.nix
{ inputs, username }:
{ config, pkgs, ... }: {
  imports = [
    (import ./languages { inherit inputs; })
    (import ./tools.nix { inherit inputs; })
    (import ./containers.nix { inherit inputs username; })
    (import ./virtualization.nix { inherit inputs; })
  ];

  # Common development packages
  environment.systemPackages = with pkgs; [
    docker-compose
    insomnia
    git-lfs
    meld
    antigravity        # Google's AI-first IDE (VS Code fork)
  ];

  # Allow unfree packages moved to flake.nix to avoid home-manager warning
}