{ config, pkgs, inputs, username, lib, ... }: {
  imports = [
    ./hardware-configuration.nix

    # Profiles
    (import ../../profiles/base { inherit inputs username; })
    (import ../../profiles/development { inherit inputs username; })
    (import ../../core/drivers/intel.nix)
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
  hardware.facetimehd.enable = lib.mkDefault false; # Enable if webcam needed (requires firmware extraction)

  # Power management for MacBook
  services.tlp = {
    enable = true;
    settings = {
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
      # MacBook battery thresholds (if supported)
      START_CHARGE_THRESH_BAT0 = 75;
      STOP_CHARGE_THRESH_BAT0 = 80;
    };
  };
  services.power-profiles-daemon.enable = false;

  # Lid switch behavior
  services.logind.settings.Login = {
    HandleLidSwitch = "suspend";
    HandleLidSwitchExternalPower = "ignore";
    HandleLidSwitchDocked = "ignore";
  };

  # Trackpad - Apple trackpad works with libinput
  services.libinput = {
    enable = true;
    touchpad = {
      naturalScrolling = true;
      tapping = true;
      clickMethod = "clickfinger"; # Two-finger right-click
      disableWhileTyping = true;
    };
  };

  # Keyboard - Apple keyboard tweaks
  services.xserver.xkb = {
    options = "altwin:swap_lalt_lwin"; # Swap Alt and Cmd for more natural layout
  };

  # Backlight control
  programs.light.enable = true;

  # Firmware updates
  services.fwupd.enable = true;

  environment.systemPackages = with pkgs; [
    # Monitoring tools
    lm_sensors
    powertop

    # Backlight control
    acpilight

    # Graphics
    mesa
    mesa-demos
  ];

  networking = {
    hostName = "macbook";
  };

  system.stateVersion = "25.11";
}
