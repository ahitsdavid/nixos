# Hyprland default.nix
{ pkgs, ... }: {
  
  imports = [
    (import ./hyprland.nix )
    (import ./env.nix )
    (import ./general.nix )
    (import ./keybinds.nix )
    (import ./execs.nix )

  ];
}