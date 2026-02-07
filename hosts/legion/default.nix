{ config, pkgs, inputs, username, lib, ... }: {
  imports = [
    ./hardware-configuration.nix

    # Profiles
    (import ../../profiles/base { inherit inputs username; })
    (import ../../profiles/development { inherit inputs username; })
    (import ../../profiles/work { inherit inputs username; })
    ../../profiles/laptop

    # Hybrid graphics (BIOS set to Dynamic/Hybrid)
    ../../core/drivers/intel.nix
    ../../core/drivers/nvidia.nix

    # Waydroid - uses Intel iGPU for proper GPU acceleration
    ../../core/modules/waydroid.nix
  ];

  # Enable both graphics drivers
  drivers.intel.enable = true;
  drivers.nvidia.enable = true;

  # NVIDIA Prime - Intel handles displays, NVIDIA for compute/gaming
  hardware.nvidia.prime = {
    sync.enable = true;
    intelBusId = "PCI:0:2:0";
    nvidiaBusId = "PCI:1:0:0";
  };

  # Kernel - latest for best NVIDIA support
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelParams = [
    "nvidia-drm.modeset=1"
    "nvidia.NVreg_PreserveVideoMemoryAllocations=1"
  ];

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Override: use power-profiles-daemon instead of TLP
  services.tlp.enable = false;
  services.power-profiles-daemon.enable = true;

  # Override: disable thermald (NVIDIA handles its own thermals)
  services.thermald.enable = false;

  # Hardware acceleration for gaming
  hardware.graphics = {
    enable = true;
    enable32Bit = true; # Required for 32-bit games/Steam
  };

  # Legion-specific packages
  environment.systemPackages = with pkgs; [
    vulkan-tools
    nvtopPackages.nvidia
    pciutils
    usbutils
  ];

  networking.hostName = "legion";

  # Ethernet sharing - can be gateway (when docked) or client (when work-intel is docked)
  networking.ethernet-share.gateway = {
    enable = false;
    interface = "enp66s0";
  };
  networking.ethernet-share.client = {
    enable = true;
    interface = "enp66s0";
  };

  # stateVersion: Set at initial install - do not change
  system.stateVersion = "25.05";
}
