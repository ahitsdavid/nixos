# Hyprland default.nix
{ pkgs, config, lib, hostname ? "unknown", ... }:
let
  # Hosts with NVIDIA GPUs that need NVIDIA-specific env vars
  hasNvidia = hostname == "desktop" || hostname == "legion";
in {

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