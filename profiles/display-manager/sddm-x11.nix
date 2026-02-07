# SDDM with X11 backend
# Used by: work-intel (Wayland SDDM has rendering issues on hybrid GPU)
{ pkgs, lib, config, username, ... }:
{
  imports = [
    ./sddm-wayland.nix
  ];

  # Override to use X11 backend
  services.displayManager.sddm.wayland.enable = lib.mkForce false;
}
