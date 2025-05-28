# Hyprland default.nix
{ pkgs, ... }: {
  
  imports = [
    (import ./hypridle.nix )
    (import ./hyprland.nix )
    (import ./hyprlock.nix)
    (import ./env.nix )
    (import ./general.nix )
    (import ./keybinds.nix )
    (import ./execs.nix )

  ];
}