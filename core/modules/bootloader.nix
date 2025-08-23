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

  # Kernel parameters to suppress boot messages and improve display manager experience
  boot.kernelParams = [
    "quiet"              # Suppress most boot messages
    "splash"             # Enable splash screen
    "loglevel=3"         # Only show error messages
    "rd.systemd.show_status=false"  # Hide systemd status messages during initrd
    "rd.udev.log_level=3"           # Reduce udev log level
    "udev.log_priority=3"           # Reduce udev log priority
  ];

  # Console settings for better display manager experience
  boot.consoleLogLevel = 0;
  boot.initrd.systemd.enable = true;
  
  # Preserve old generations for rollbacks
  boot.bootspec.enable = true;
}
  