# Hyprland default.nix
{ pkgs, config, lib, hostname ? "unknown", ... }: 
let
  isDesktop = hostname == "desktop";
in {
  
  imports = [
    (import ./hypridle.nix )
    (import ./hyprland.nix )
    (import ./hyprlock.nix)
    (import ./general.nix )
    (import ./colors.nix )
    (import ./keybinds.nix )
    (import ./execs.nix )
    (import ./rules.nix )
  ] ++ lib.optionals isDesktop [
    (import ./env-nvidia.nix )
  ] ++ lib.optionals (!isDesktop) [
    (import ./env.nix )
  ];

}