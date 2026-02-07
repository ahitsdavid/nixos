# profiles/laptop/default.nix - Common laptop configuration
# Imports power management, input devices, and firmware modules
# All settings use mkDefault so hosts can override as needed
{ config, lib, pkgs, ... }:
{
  imports = [
    ./power-management.nix
    ./input-devices.nix
    ./firmware.nix
  ];

  # Common laptop packages
  environment.systemPackages = with pkgs; [
    # Power/thermal monitoring
    lm_sensors
    powertop
    acpi

    # Graphics baseline
    mesa
    mesa-demos
  ];

  # Lid switch defaults - suspend on lid close
  services.logind.settings.Login = {
    HandleLidSwitch = lib.mkDefault "suspend";
    HandleLidSwitchExternalPower = lib.mkDefault "ignore";
    HandleLidSwitchDocked = lib.mkDefault "ignore";
  };

  # Backlight control (brightnessctl/light without root)
  programs.light.enable = lib.mkDefault true;
}
