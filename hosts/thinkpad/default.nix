{ config, pkgs, inputs, username, lib, ... }: {
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix

      # Profiles
      (import ../../profiles/base { inherit inputs username; })
      (import ../../profiles/development { inherit inputs username; })
      (import ../../profiles/work { inherit inputs username; })
      (import ../../core/drivers/intel.nix )
    ];
  # Kernel
  boot.kernelPackages = pkgs.linuxPackages_latest;
  
  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Lidswitch set to ignore
  services.logind.settings.Login = {
    HandleLidSwitch = "ignore";
    HandleLidSwitchExternalPower = "ignore";
    HandleLidSwitchDocked = "ignore";
  };

  # TLP for advanced power management
  services.tlp = {
    enable = true;
    settings = {
      # Optimize for battery life
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
      
      # Battery charge thresholds (important for battery longevity)
      START_CHARGE_THRESH_BAT0 = 75;  # Start charging when below 75%
      STOP_CHARGE_THRESH_BAT0 = 80;   # Stop charging when above 80%
      
      # For external battery if you have one
      START_CHARGE_THRESH_BAT1 = 75;
      STOP_CHARGE_THRESH_BAT1 = 80;
    };
  };
  
  # Power profiles daemon (alternative to TLP)
  services.power-profiles-daemon.enable = false; # Disable if using TLP

  # Trackpad Settings
# For your NixOS configuration.nix, you mainly need:
services.libinput.enable = true;  # Basic libinput support

# Hardware trackpoint config (keep your existing)
hardware.trackpoint = {
  enable = true;
  sensitivity = 255;
  speed = 120;
  emulateWheel = true;
};
      
  # Fingerprint reader
  services.fprintd.enable = true;
  
  # Thunderbolt support
  services.hardware.bolt.enable = true;
  
  # For Thunderbolt docks
  hardware.enableAllFirmware = true;

  # Add powertop for power analysis
  environment.systemPackages = with pkgs; [ 
    # Monitoring tools
    lm_sensors
    powertop 
    thinkfan
    
    # ThinkPad utilities
    tpacpi-bat
    acpi
    
    # For keyboard backlight control
    acpilight
    
    # Video4Linux utilities
    v4l-utils

    mesa
    mesa-demos
  ];

  services.throttled.enable = true;
  services.fwupd.enable = true;

  networking = {
    hostName = "thinkpad";
  };

  # stateVersion: Set at initial install - do not change
  system.stateVersion = "25.05";
}
