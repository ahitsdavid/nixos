#profiles/development/languages/default.nix
{ inputs }:
{ config, pkgs, ... }: {
  imports = [
    (import ./python.nix { inherit inputs; })
  ];
  # Common language tools
  environment.systemPackages = with pkgs; [
    gcc
    gnumake
    nodejs
    yarn
    go
  ];
}