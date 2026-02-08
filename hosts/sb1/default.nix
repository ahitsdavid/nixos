{ config, pkgs, inputs, username, lib, ... }: {
  imports = [
    ./hardware-configuration.nix

    # Profiles
    (import ../../profiles/base { inherit inputs username; })
    (import ../../profiles/development { inherit inputs username; })
    (import ../../profiles/work { inherit inputs username; })  # CAC support
    ../../profiles/laptop
    ../../profiles/surface
    ../../profiles/gnome-tablet
    ../../core/drivers/intel.nix
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
