{ config, pkgs, inputs, username, lib, ... }: {
  imports = [
    ./hardware-configuration.nix
  ];

  # Kernel
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Override: lid switch ignored (typically docked)
  services.logind.settings.Login = {
    HandleLidSwitch = "ignore";
    HandleLidSwitchExternalPower = "ignore";
    HandleLidSwitchDocked = "ignore";
  };

  # ThinkPad trackpoint
  hardware.trackpoint = {
    enable = true;
    sensitivity = 255;
    speed = 120;
  };

  # ThinkPad-specific: fingerprint reader
  services.fprintd.enable = true;

  # ThinkPad-specific: Thunderbolt support
  services.hardware.bolt.enable = true;
  hardware.enableAllFirmware = true;

  # ThinkPad-specific: thermal throttling fix
  services.throttled.enable = true;

  # ThinkPad-specific packages
  environment.systemPackages = with pkgs; [
    thinkfan
    tpacpi-bat
    acpilight
    v4l-utils
  ];

  networking.hostName = "thinkpad";

  # stateVersion: Set at initial install - do not change
  system.stateVersion = "25.05";
}
