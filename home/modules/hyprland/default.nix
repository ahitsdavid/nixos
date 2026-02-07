# Hyprland default.nix
{ pkgs, config, lib, inputs, ... }:
{
  # Symlink hyprland scripts from end-4 dots
  home.file.".config/hypr/hyprland/scripts".source = "${inputs.dots-hyprland}/dots/.config/hypr/hyprland/scripts";

  imports = [
    ./hypridle.nix
    ./hyprland.nix
    ./hyprlock.nix
    ./general.nix
    ./colors.nix
    ./keybinds.nix
    ./execs.nix
    ./rules.nix
    ./env.nix        # Common env vars for all hosts
    ./env-nvidia.nix # NVIDIA env vars (conditionally applied via mkIf)
  ];
}