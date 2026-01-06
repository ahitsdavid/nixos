{ config, pkgs, inputs, username, lib, ... }: {
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix

      # Profiles
      (import ../../profiles/base { inherit inputs username; })
      (import ../../profiles/development { inherit inputs username; })
      (import ../../core/drivers/nvidia.nix)
    ];

  # Kernel - using latest for best Nvidia support
  boot.kernelPackages = pkgs.linuxPackages_latest;
  
  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Desktop-specific power management (no battery optimization needed)
  services.power-profiles-daemon.enable = true;
  
  # Hardware acceleration
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  # Gaming support
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
  };

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

  networking.hostName = "desktop";

  system.stateVersion = "25.05";
}