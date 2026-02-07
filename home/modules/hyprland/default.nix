# Hyprland default.nix
{ pkgs, config, lib, inputs, ... }:
{
  # Symlink hyprland scripts from end-4 dots
  home.file.".config/hypr/hyprland/scripts".source = "${inputs.dots-hyprland}/dots/.config/hypr/hyprland/scripts";

  imports = [
    (import ./hypridle.nix )
    (import ./hyprland.nix )
    (import ./hyprlock.nix)
    (import ./general.nix )
    (import ./colors.nix )
    (import ./keybinds.nix )
    (import ./execs.nix )
    (import ./rules.nix )
    (import ./env.nix )       # Common env vars for all hosts
    (import ./env-nvidia.nix) # NVIDIA env vars (conditionally applied via mkIf)
  ];
}