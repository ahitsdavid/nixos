{
  lib,
  pkgs,
  config,
  ...
}:
with lib; let
  cfg = config.drivers.nvidia;
in {
  options.drivers.nvidia = {
    enable = mkEnableOption "Enable Nvidia Graphics Drivers";
  };

  config = mkIf cfg.enable {
    # Enable OpenGL
    hardware.graphics = {
      enable = true;
      enable32Bit = true;
    };

    # Load nvidia driver for Xorg and Wayland
    services.xserver.videoDrivers = ["nvidia"];

    hardware.nvidia = {
      # Modesetting is required for Wayland
      modesetting.enable = true;

      # Nvidia power management (experimental, might cause issues)
      powerManagement.enable = false;
      powerManagement.finegrained = false;

      # Use the open source version of the kernel module (only for RTX 20xx and newer)
      # Disabled: open modules have EGL/Wayland issues (eglCreateImage failures)
      open = false;

      # Enable the Nvidia settings menu
      nvidiaSettings = true;

      # Select the appropriate driver version for your hardware
      package = config.boot.kernelPackages.nvidiaPackages.stable;
    };

    # Enable nvidia-vaapi-driver for hardware acceleration
    environment.systemPackages = with pkgs; [
      nvidia-vaapi-driver
      egl-wayland  # Required for EGL on Wayland with NVIDIA
    ];

    # Environment variables for Wayland/Hyprland
    environment.sessionVariables = {
      # Nvidia Wayland variables
      LIBVA_DRIVER_NAME = "nvidia";
      XDG_SESSION_TYPE = "wayland";
      GBM_BACKEND = "nvidia-drm";
      __GLX_VENDOR_LIBRARY_NAME = "nvidia";
      WLR_NO_HARDWARE_CURSORS = "1";
    };
  };
}