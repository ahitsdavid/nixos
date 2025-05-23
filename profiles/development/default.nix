# profiles/development/default.nix
{ inputs, username }:
{ config, pkgs, ... }: {
  imports = [
    (import ./languages { inherit inputs; })
    (import ./tools.nix { inherit inputs; })
  ];

  # Common development packages
  environment.systemPackages = with pkgs; [
    vscode
    docker-compose
    insomnia
    git-lfs
    meld
  ];

  #Development services
  virtualisation.docker.enable = true;

  # Allow unfree packages (for VSCode, etc,)
  nixpkgs.config.allowUnfree = true;
}