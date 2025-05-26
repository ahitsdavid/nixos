{ config, pkgs, inputs, username, ... }: {
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix

      # Profiles
      (import ../../profiles/base { inherit inputs username; })
      (import ../../profiles/development { inherit inputs username; })
      (import ../../profiles/work { inherit inputs username; })
      (import ../../drivers/intel.nix )
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Lidswitch set to ignore
  services.logind = {
    lidSwitch = "ignore";
    lidSwitchExternalPower = "ignore";
    lidSwitchDocked = "ignore";
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

  # ThinkPad ACPI support
  hardware.trackpoint = {
    enable = true;
    sensitivity = 255;
    speed = 97;
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
    
    # Firmware updates
    fwupd
    
    # For keyboard backlight control
    acpilight
    
    # Video4Linux utilities
    v4l-utils  
  ];


  # boot = {
  #   kernelModules = [ "thinkpad_acpi" ];
  #   extraModprobeConfig = ''
  #     options thinkpad_acpi fan_control=1
  #   '';
  # };
  # # ThinkPad fan control
  # services.thinkfan = {
  #   enable = true;
    
  #   # Use hwmon with a more flexible path pattern
  #   sensors = [
  #     {
  #       type = "hwmon";
  #       # More generic pattern that works across reboots
  #       query = "/sys/class/thermal/thermal_zone*/temp";
  #     }
  #   ];
    
  #   # Alternative approach using specific paths if the above doesn't work
  #   # sensors = [
  #   #   {
  #   #     type = "hwmon";
  #   #     query = "/sys/devices/platform/coretemp.0/hwmon/hwmon*/temp1_input";
  #   #   }
  #   # ];
    
  #   levels = [
  #     [ 0 0 55 ]
  #     [ 1 48 60 ]
  #     [ 2 50 61 ]
  #     [ 3 52 63 ]
  #     [ 4 56 65 ]
  #     [ 5 59 66 ]
  #     [ 7 63 32767 ]
  #   ];

  #   extraArgs = [ "-b" "0" "-q" ];
  # };

  # systemd.services.thinkfan = {
  #   after = [ "systemd-modules-load.service" ];
  #   requires = [ "systemd-modules-load.service" ];
  # };

  networking.hostName = "thinkpad";

  system.stateVersion = "25.05";

}
