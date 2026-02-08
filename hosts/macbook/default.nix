{ config, pkgs, inputs, username, lib, ... }: {
  imports = [
    ./hardware-configuration.nix

    # Profiles
    (import ../../profiles/base { inherit inputs username; })
    (import ../../profiles/development { inherit inputs username; })
    ../../profiles/laptop
    ../../core/drivers/intel.nix
  ];

  # Kernel
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Broadcom WiFi driver
  boot.kernelModules = [ "wl" ];
  boot.extraModulePackages = [ config.boot.kernelPackages.broadcom_sta ];
  hardware.enableAllFirmware = true;

  # Allow insecure broadcom-sta
  nixpkgs.config.allowInsecurePredicate = pkg:
    builtins.elem (builtins.parseDrvName pkg.name).name [
      "broadcom-sta"
    ];

  # Apple keyboard/input support
  hardware.facetimehd.enable = lib.mkDefault false;

  # Apple keyboard tweaks
  services.xserver.xkb = {
    options = "altwin:swap_lalt_lwin"; # Swap Alt and Cmd
  };

  # GNOME Desktop Environment
  services.xserver.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  # GNOME requires power-profiles-daemon, not TLP
  services.power-profiles-daemon.enable = lib.mkForce true;
  services.tlp.enable = lib.mkForce false;
  environment.gnome.excludePackages = with pkgs; [
    gnome-tour
    epiphany
    geary
    gnome-music
  ];

  # Host-specific packages
  environment.systemPackages = with pkgs; [
    acpilight

    # GNOME tweaks and extensions
    gnome-tweaks
    gnome-extension-manager
    gnomeExtensions.caffeine
    gnomeExtensions.appindicator
    gnomeExtensions.dash-to-dock
    gnomeExtensions.clipboard-indicator
    gnomeExtensions.blur-my-shell
    gnomeExtensions.vitals
  ];

  networking.hostName = "macbook";

  # stateVersion: Set at initial install - do not change
  system.stateVersion = "25.11";
}
