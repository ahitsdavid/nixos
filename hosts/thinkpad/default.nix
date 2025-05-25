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

  networking.hostName = "thinkpad";

  system.stateVersion = "25.05";

}
