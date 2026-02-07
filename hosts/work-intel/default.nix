{ config, pkgs, inputs, username, lib, ... }: {
  imports = [
    ./hardware-configuration.nix

    # Profiles
    (import ../../profiles/base { inherit inputs username; })
    (import ../../profiles/development { inherit inputs username; })
    (import ../../profiles/work { inherit inputs username; })
    ../../profiles/laptop

    # Hybrid graphics: offload mode for battery life
    (import ../../core/drivers/hybrid-gpu.nix {
      mode = "offload";
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
    })
  ];

  # Use X11 for SDDM (Wayland SDDM has rendering issues)
  services.displayManager.sddm.wayland.enable = lib.mkForce false;

  # Kernel
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelParams = [
    "mem_sleep_default=deep" # Force S3 deep sleep instead of s2idle
  ];

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Override: lid switch ignored (typically docked to external monitor)
  services.logind.settings.Login = {
    HandleLidSwitch = "ignore";
    HandleLidSwitchExternalPower = "ignore";
    HandleLidSwitchDocked = "ignore";
  };

  # GNOME Desktop Environment (SDDM from core modules handles login)
  services.desktopManager.gnome.enable = true;
  environment.gnome.excludePackages = with pkgs; [
    gnome-tour
    epiphany
    geary
    gnome-music
  ];

  # Override TLP: aggressive thermal settings for i9
  services.tlp.settings = {
    CPU_SCALING_GOVERNOR_ON_AC = "powersave";
    CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
    CPU_ENERGY_PERF_POLICY_ON_AC = "balance_power";
    CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
    # Disable turbo boost (biggest heat reduction)
    CPU_BOOST_ON_AC = 0;
    CPU_BOOST_ON_BAT = 0;
    CPU_HWP_DYN_BOOST_ON_AC = 0;
    CPU_HWP_DYN_BOOST_ON_BAT = 0;
  };

  # Trackpoint
  hardware.trackpoint = {
    enable = true;
    sensitivity = 255;
    speed = 120;
  };

  # Fingerprint reader
  services.fprintd.enable = true;

  # Thunderbolt/USB-C dock support
  services.hardware.bolt.enable = true;
  hardware.enableAllFirmware = true;

  # Disable USB autosuspend for Dell dock
  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="413c", ATTR{power/autosuspend}="-1"
    ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="0bda", ATTR{power/autosuspend}="-1"
  '';

  # Host-specific packages
  environment.systemPackages = with pkgs; [
    s-tui
    acpilight
    v4l-utils

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

  networking.hostName = "work-intel";

  # Ethernet sharing
  networking.ethernet-share.gateway = {
    enable = true;
    interface = "enp0s20f0u2";
  };
  networking.ethernet-share.client = {
    enable = false;
    interface = "enp0s20f0u2";
  };

  # stateVersion: Set at initial install - do not change
  system.stateVersion = "25.05";
}
