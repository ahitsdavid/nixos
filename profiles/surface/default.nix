# profiles/surface/default.nix
# Microsoft Surface hardware support
{ config, lib, pkgs, ... }:
{
  imports = [ ./touch.nix ];

  # Enable all firmware for Surface devices
  hardware.enableAllFirmware = true;
  hardware.enableRedistributableFirmware = true;

  # Firmware updates
  services.fwupd.enable = true;

  # Auto-rotate screen with accelerometer
  hardware.sensor.iio.enable = true;

  # Surface-specific packages
  environment.systemPackages = with pkgs; [
    surface-control  # Surface device control utility
    brightnessctl    # Brightness control
  ];
}
