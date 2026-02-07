# profiles/laptop/input-devices.nix - Laptop input device configuration
# Touchpad and trackpoint settings with sensible defaults
{ config, lib, pkgs, ... }:
{
  # Libinput for touchpad support
  services.libinput = {
    enable = lib.mkDefault true;
    touchpad = {
      naturalScrolling = lib.mkDefault true;
      tapping = lib.mkDefault true;
      clickMethod = lib.mkDefault "clickfinger"; # Two-finger right-click
      disableWhileTyping = lib.mkDefault true;
    };
  };

  # Trackpoint support (ThinkPads, some Dell/HP laptops)
  # Disabled by default - enable in host config if hardware present
  hardware.trackpoint = {
    enable = lib.mkDefault false;
    emulateWheel = lib.mkDefault true;
  };
}
