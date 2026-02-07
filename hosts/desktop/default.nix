{ config, pkgs, inputs, username, lib, ... }: {
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix

      # Profiles
      (import ../../profiles/base { inherit inputs username; })
      (import ../../profiles/development { inherit inputs username; })
      (import ../../profiles/work { inherit inputs username; })
      (import ../../core/drivers/nvidia.nix)
    ];

  # Kernel - using latest for best Nvidia support
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Bootloader with CachyOS entries
  boot.loader.systemd-boot = {
    enable = true;
    # Copy CachyOS kernels from its EFI partition to NixOS EFI
    extraFiles = {
      "cachyos-vmlinuz" = "/mnt/cachyos-efi/vmlinuz-linux-cachyos";
      "cachyos-initramfs.img" = "/mnt/cachyos-efi/initramfs-linux-cachyos.img";
      "cachyos-amd-ucode.img" = "/mnt/cachyos-efi/amd-ucode.img";
    };
    # Add manual boot entries for CachyOS
    extraEntries = {
      "cachyos.conf" = ''
        title CachyOS Linux
        linux /cachyos-vmlinuz
        initrd /cachyos-amd-ucode.img
        initrd /cachyos-initramfs.img
        options quiet zswap.enabled=0 nowatchdog splash rw rootflags=subvol=/@ root=UUID=7c2382d2-72b2-4a3f-bca7-61fc73dd31c3
      '';
    };
  };
  boot.loader.efi.canTouchEfiVariables = true;

  # Mount CachyOS EFI partition so we can access its kernel files
  fileSystems."/mnt/cachyos-efi" = {
    device = "/dev/disk/by-uuid/A9F6-13B4";
    fsType = "vfat";
    options = [ "ro" "nofail" ];
  };

  # Desktop-specific power management (no battery optimization needed)
  services.power-profiles-daemon.enable = true;

  # Hardware acceleration
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  # Enable NVIDIA drivers
  drivers.nvidia.enable = true;

  # Desktop-specific packages (monitoring, graphics, system from core)
  environment.systemPackages = with pkgs; [
    nvidia-vaapi-driver
    nvtopPackages.full
    ryzen-monitor-ng
  ];

  # Kernel parameters for AMD 7800X3D + Nvidia
  boot.kernelParams = [
    # Nvidia settings
    "nvidia-drm.modeset=1"
    "nvidia.NVreg_PreserveVideoMemoryAllocations=1"

    # AMD CPU optimizations
    "amd_pstate=active"
  ];

  networking.hostName = "desktop";

  # stateVersion: Set at initial install - do not change
  system.stateVersion = "25.05";
}
