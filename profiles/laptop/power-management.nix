# profiles/laptop/power-management.nix - Laptop power management
# TLP enabled by default with conservative settings
# Override with services.tlp.enable = false and services.power-profiles-daemon.enable = true for alternative
{ config, lib, pkgs, ... }:
{
  # TLP for battery optimization (default)
  services.tlp = {
    enable = lib.mkDefault true;
    settings = {
      # CPU governors
      CPU_SCALING_GOVERNOR_ON_AC = lib.mkDefault "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = lib.mkDefault "powersave";

      # Battery charge thresholds for longevity (common across ThinkPads, Dell, etc.)
      START_CHARGE_THRESH_BAT0 = lib.mkDefault 75;
      STOP_CHARGE_THRESH_BAT0 = lib.mkDefault 80;
      START_CHARGE_THRESH_BAT1 = lib.mkDefault 75;
      STOP_CHARGE_THRESH_BAT1 = lib.mkDefault 80;
    };
  };

  # Power profiles daemon (alternative to TLP) - disabled by default
  # Enable this and disable TLP for GNOME power profiles integration
  services.power-profiles-daemon.enable = lib.mkDefault false;

  # Thermal management
  services.thermald.enable = lib.mkDefault true;
}
