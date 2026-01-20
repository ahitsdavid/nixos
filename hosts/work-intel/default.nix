{ config, pkgs, inputs, username, lib, ... }: {
  imports = [
    ./hardware-configuration.nix

    # Profiles
    (import ../../profiles/base { inherit inputs username; })
    (import ../../profiles/development { inherit inputs username; })
    (import ../../profiles/work { inherit inputs username; })

    # Intel integrated graphics
    ../../core/drivers/intel.nix
  ];

  # Enable Intel graphics driver
  drivers.intel.enable = true;

  # Kernel
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Lid switch ignored (typically docked to external monitor)
  services.logind.settings.Login = {
    HandleLidSwitch = "ignore";
    HandleLidSwitchExternalPower = "ignore";
    HandleLidSwitchDocked = "ignore";
  };

  # GNOME Desktop Environment (SDDM from core modules handles login)
  services.desktopManager.gnome.enable = true;

  # TLP for power management
  services.tlp = {
    enable = true;
    settings = {
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";

      # Battery charge thresholds for longevity
      START_CHARGE_THRESH_BAT0 = 75;
      STOP_CHARGE_THRESH_BAT0 = 80;
      START_CHARGE_THRESH_BAT1 = 75;
      STOP_CHARGE_THRESH_BAT1 = 80;
    };
  };

  # Disable power-profiles-daemon when using TLP
  services.power-profiles-daemon.enable = false;

  # Input devices
  services.libinput.enable = true;

  # Trackpoint (if present)
  hardware.trackpoint = {
    enable = true;
    sensitivity = 255;
    speed = 120;
    emulateWheel = true;
  };

  # Fingerprint reader (if present)
  services.fprintd.enable = true;

  # Thunderbolt/USB-C dock support
  services.hardware.bolt.enable = true;
  hardware.enableAllFirmware = true;

  # System packages
  environment.systemPackages = with pkgs; [
    # Monitoring
    lm_sensors
    powertop
    acpi

    # Keyboard backlight
    acpilight

    # Video/camera utilities
    v4l-utils

    # Graphics
    mesa
    mesa-demos
  ];

  # Intel throttling fix
  services.throttled.enable = true;

  # Firmware updates
  services.fwupd.enable = true;

  networking.hostName = "work-intel";

  system.stateVersion = "25.05";
}
