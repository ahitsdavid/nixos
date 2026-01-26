# Hyprland default.nix
{ pkgs, config, lib, inputs, hostname ? "unknown", ... }:
let
  # Hosts with NVIDIA GPUs that need NVIDIA-specific env vars
  hasNvidia = hostname == "desktop" || hostname == "legion";
in {

  # Symlink hyprland scripts from end-4 dots
  home.file.".config/hypr/hyprland/scripts".source = "${inputs.dots-hyprland}/dots/.config/hypr/hyprland/scripts";

  imports = [
    (import ./hypridle.nix )
    (import ./hyprland.nix )
    (import ./hyprlock.nix)
    (import ./general.nix )
    (import ./colors.nix )
    (import ./keybinds.nix ) # Now includes both submap changes and cheatsheet compatibility
    (import ./execs.nix )
    (import ./rules.nix )
  ] ++ lib.optionals hasNvidia [
    (import ./env-nvidia.nix )
  ] ++ lib.optionals (!hasNvidia) [
    (import ./env.nix )
  ];

}