# Hybrid GPU configuration for Intel + NVIDIA laptops
# Supports both offload mode (power saving) and sync mode (performance)
{
  mode ? "offload", # "offload" or "sync"
  intelBusId,
  nvidiaBusId,
}:
{
  config,
  lib,
  pkgs,
  ...
}:
let
  isOffload = mode == "offload";
  isSync = mode == "sync";
in
{
  imports = [
    ./intel.nix
    ./nvidia.nix
  ];

  # Enable both drivers
  drivers.intel.enable = true;
  drivers.nvidia.enable = true;

  # NVIDIA Prime configuration
  hardware.nvidia.prime = {
    inherit intelBusId nvidiaBusId;

    offload = lib.mkIf isOffload {
      enable = true;
      enableOffloadCmd = true; # Provides nvidia-offload command
    };

    sync.enable = lib.mkIf isSync true;
  };

  # Power management: enable for offload mode to save battery
  hardware.nvidia.powerManagement = lib.mkIf isOffload {
    enable = lib.mkForce true;
    finegrained = lib.mkForce true; # Power down GPU when idle (Turing+)
  };

  # Environment variables: use Intel for VAAPI in offload mode
  environment.sessionVariables = lib.mkIf isOffload (lib.mkForce {
    LIBVA_DRIVER_NAME = "iHD"; # Intel for hardware video accel
  });

  # Kernel params for sync mode (always-on NVIDIA)
  boot.kernelParams = lib.mkIf isSync [
    "nvidia-drm.modeset=1"
    "nvidia.NVreg_PreserveVideoMemoryAllocations=1"
  ];

  # Common packages for hybrid systems
  environment.systemPackages = with pkgs; [
    vulkan-tools
    nvtopPackages.nvidia
    pciutils
  ];
}
