# profiles/laptop/firmware.nix - Laptop firmware configuration
# Enables firmware updates and redistributable firmware
{ config, lib, pkgs, ... }:
{
  # Firmware update daemon
  services.fwupd.enable = lib.mkDefault true;

  # Enable redistributable firmware (WiFi, Bluetooth, etc.)
  hardware.enableRedistributableFirmware = lib.mkDefault true;
}
