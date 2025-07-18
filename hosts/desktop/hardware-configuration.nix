# Template hardware configuration for Intel i7-8700K + Nvidia 3070Ti desktop
# This will be replaced by nixos-generate-config during installation
{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  # CPU - Intel i7-8700K (Coffee Lake)
  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "usbhid" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  # Placeholder filesystem configuration - will be auto-generated
  fileSystems."/" =
    { device = "/dev/disk/by-uuid/PLACEHOLDER";
      fsType = "ext4";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/PLACEHOLDER";
      fsType = "vfat";
      options = [ "fmask=0022" "dmask=0022" ];
    };

  swapDevices = [ ];

  # Intel CPU features
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  
  # Enable hardware acceleration
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}