# Quickshell default.nix
{ pkgs, ... }: {
  
  imports = [
    (import ./quickshell.nix )
  ];
}