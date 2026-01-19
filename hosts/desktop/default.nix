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

  # Gaming support
  #programs.steam = {
  #enable = true;
  #remotePlay.openFirewall = true;
  # dedicatedServer.openFirewall = true;
  #};
  services.desktopManager.gnome.enable = true;
  # Desktop utilities
  environment.systemPackages = with pkgs; [
    # Monitoring tools
    lm_sensors
    nvidia-vaapi-driver

    # GPU utilities
    mesa
    mesa-demos
    nvtopPackages.full

    # AMD CPU utilities
    ryzen-monitor-ng

    # Desktop utilities
    pciutils
    usbutils
  ];

  # Kernel parameters for AMD 7800X3D + Nvidia
  boot.kernelParams = [
    # Nvidia settings
    "nvidia-drm.modeset=1"
    "nvidia.NVreg_PreserveVideoMemoryAllocations=1"

    # AMD CPU optimizations
    "amd_pstate=active"
  ];

  # SDDM monitor configuration for desktop
  # Ensure login screen appears on main monitor (DP-5) not the rotated secondary (DP-4)
  services.displayManager.sddm.settings = {
    General = {
      # Display the greeter on the main monitor
      DisplayServer = "wayland";
    };
    Wayland = {
      # Set the compositor command with monitor configuration
      CompositorCommand = "${pkgs.writeScript "sddm-hyprland-wrapper" ''
        #!/bin/sh
        # Configure monitors for SDDM greeter - show only on main display
        export HYPRLAND_LOG_WLR=1
        # Launch Hyprland with monitor configuration for login screen
        ${pkgs.hyprland}/bin/Hyprland -c ${pkgs.writeText "sddm-hyprland.conf" ''
          monitor=DP-5,3440x1440@100,0x0,1
          monitor=DP-4,disable
        ''}
      ''}";
    };
  };

  networking.hostName = "desktop";

  system.stateVersion = "25.05";
}
