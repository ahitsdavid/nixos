# core/modules/bootloader.nix
{ pkgs, ... }: {
  # Bootloader.
  boot.loader = {
    systemd-boot = {
      enable = true;
      configurationLimit = 10;
      editor = false;
    };
    efi = {
      canTouchEfiVariables = true;
      efiSysMountPoint = "/boot";
    };

    # boot menu timeout
    timeout = 5;
  };

  
  # Preserve old generations for rollbacks
  boot.bootspec.enable = true;
}
  