{ config, pkgs, inputs, username, lib, ... }: {
  imports = [
    ./hardware-configuration.nix

    # Profiles
    (import ../../profiles/base { inherit inputs username; })
    (import ../../profiles/development { inherit inputs username; })
    (import ../../profiles/work { inherit inputs username; })

    # Intel integrated graphics
    ../../core/drivers/intel.nix
    # NVIDIA discrete graphics
    ../../core/drivers/nvidia.nix
  ];

  # Enable Intel graphics driver
  drivers.intel.enable = true;

  # Enable NVIDIA driver for hybrid graphics
  drivers.nvidia.enable = true;

  # NVIDIA Prime for hybrid GPU switching (offload mode saves power)
  hardware.nvidia.prime = {
    offload = {
      enable = true;
      enableOffloadCmd = true;  # Provides nvidia-offload command
    };
    # Run `lspci | grep -E 'VGA|3D'` to verify these bus IDs
    intelBusId = "PCI:0:2:0";
    nvidiaBusId = "PCI:1:0:0";
  };

  # Override nvidia.nix env vars - use Intel by default for offload mode
  environment.sessionVariables = lib.mkForce {
    LIBVA_DRIVER_NAME = "iHD";  # Intel for hardware video accel
  };

  # Use X11 for SDDM (Wayland SDDM has rendering issues)
  services.displayManager.sddm.wayland.enable = lib.mkForce false;

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

  # Backlight control (allows brightnessctl without root)
  programs.light.enable = true;

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

  # Disable USB autosuspend for Dell dock (prevents monitor freezing)
  services.udev.extraRules = ''
    # Dell dock devices - disable autosuspend to prevent disconnects
    ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="413c", ATTR{power/autosuspend}="-1"
    ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="0bda", ATTR{power/autosuspend}="-1"
  '';

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
    mesa-demos  # includes glxinfo
    vulkan-tools
    nvtopPackages.nvidia  # GPU monitoring with NVIDIA support
  ];

  # Intel throttling fix
  services.throttled.enable = true;

  # Firmware updates
  services.fwupd.enable = true;

  networking.hostName = "work-intel";

  system.stateVersion = "25.05";
}
