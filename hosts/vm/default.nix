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

  # Enable VMWare/QEMU guest support
  # virtualisation.vmware.guest = true;
  services.qemuGuest.enable = true;
  services.spice-vdagentd.enable = true;

  services.xserver.enable = true;
  services.xserver.videoDrivers = [ "qxl" ];
  #boot.initrd.kernelModules = [ "virtio_pci" "virtio_blk" "virtio_gpu" ];
  #boot.kernelModules = [ "virtio_console" "virtio_gpu" "drm" ];

  # Enable SPICE guest tools
  environment.systemPackages = with pkgs; [
    spice-vdagent
    spice-gtk
  ];

  # Improve input and pointer in SPICE/QXL
  services.xserver.inputClassSections = [
    ''
      Identifier "Spice Mouse"
      MatchIsPointer "on"
      Driver "evdev"
    ''
  ];
  
  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.hostName = "vm";

  system.stateVersion = "25.05";

}
