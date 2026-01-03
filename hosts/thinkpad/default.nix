{ config, pkgs, inputs, username, lib, ... }: {
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix

      # Profiles
      (import ../../profiles/base { inherit inputs username; })
      (import ../../profiles/development { inherit inputs username; })
      (import ../../profiles/work { inherit inputs username; })
      (import ../../core/drivers/intel.nix )

      # Import the GDM customization module
      #(import ../../home/modules/gdm { inherit username lib config pkgs; })

    ];

  # Override python-validity package to fix format for nixos-unstable
  nixpkgs.overlays = [
    (final: prev: {
      python3 = prev.python3.override {
        packageOverrides = pyfinal: pyprev: {
          python-validity = pyprev.python-validity or (pyfinal.buildPythonPackage rec {
            pname = "python-validity";
            version = "0.14";
            pyproject = true;
            build-system = [ pyfinal.setuptools ];

            src = final.fetchFromGitHub {
              owner = "uunicorn";
              repo = "python-validity";
              rev = "v${version}";
              hash = "sha256-2OZmLGVPJBGuiJc1kDl8CqINUqOq+KmL3RPQ4VKPgXY=";
            };

            dependencies = with pyfinal; [
              cryptography
              pyusb
              pyyaml
              dbus-python
              pygobject3
            ];

            nativeBuildInputs = [ final.wrapGAppsNoGuiHook ];

            postPatch = ''
              substituteInPlace linux_pam/pam-validity-check \
                --replace /usr/bin/innoextract ${final.innoextract}/bin/innoextract
            '';

            postInstall = ''
              install -Dm444 dbus/io.github.uunicorn.Fprint.service -t $out/share/dbus-1/system-services
              install -Dm444 systemd/python-validity.service -t $out/lib/systemd/system
              install -Dm444 debian/python-validity.udev $out/lib/udev/rules.d/60-python-validity.rules
              install -Dm444 LICENSE $out/share/licenses/$pname/LICENSE
            '';
          });
        };
      };
      python3Packages = final.python3.pkgs;
    })
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
      
  # Fingerprint reader (Synaptics 06cb:009a)
  # Using custom python-validity package with unstable compatibility
  services."06cb-009a-fingerprint-sensor" = {
    enable = true;
    backend = "python-validity";
  };

  # Enable fingerprint authentication for login and sudo
  security.pam.services = {
    login.fprintAuth = true;
    sudo.fprintAuth = true;
    gdm.fprintAuth = true;
  };
  
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

  networking = {
    hostName = "thinkpad";
  };

  system.stateVersion = "25.05";

}
