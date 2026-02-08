# profiles/surface/touch.nix
# Touch and gesture configuration for Surface tablets
{ config, lib, pkgs, ... }:
{
  # Enable libinput for touch/touchpad
  services.libinput = {
    enable = true;
    touchpad = {
      tapping = true;
      naturalScrolling = true;
      clickMethod = "clickfinger";
    };
  };

  # Touch-related packages
  environment.systemPackages = with pkgs; [
    iio-sensor-proxy  # Sensor proxy for auto-rotation
  ];
}
