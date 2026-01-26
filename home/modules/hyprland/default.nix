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
    (import ./keybinds.nix )
    (import ./execs.nix )
    (import ./rules.nix )
    (import ./env.nix )  # Common env vars for all hosts
  ] ++ lib.optionals hasNvidia [
    (import ./env-nvidia.nix )  # NVIDIA-specific env vars
  ];

}