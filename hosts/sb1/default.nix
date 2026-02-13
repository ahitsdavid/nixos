{ config, pkgs, inputs, username, lib, ... }: {
  imports = [
    ./hardware-configuration.nix

    # Tablet + Surface-specific profiles (not auto-applied by meta flags)
    ../../profiles/surface
    ../../profiles/gnome-tablet
  ];

  # Use latest kernel for better Surface support
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Deep sleep for better battery
  boot.kernelParams = [ "mem_sleep_default=deep" ];

  # Tablet: ignore lid (detachable keyboard)
  services.logind.settings.Login = {
    HandleLidSwitch = lib.mkForce "ignore";
    HandleLidSwitchExternalPower = lib.mkForce "ignore";
    HandlePowerKey = "suspend";
  };

  # Brightness control packages
  environment.systemPackages = with pkgs; [
    acpilight
    brightnessctl
  ];

  networking.hostName = "sb1";

  # stateVersion: Set at initial install - do not change
  system.stateVersion = "24.11";
}
