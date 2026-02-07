# NVIDIA Wayland environment variables
# Single source of truth for all NVIDIA-related environment configuration
#
# Usage:
#   let nvidiaEnv = import ../../lib/nvidia-env.nix; in
#   - nvidiaEnv.sessionVariables  -> for environment.sessionVariables
#   - nvidiaEnv.hyprlandEnv       -> for wayland.windowManager.hyprland.settings.env
#   - nvidiaEnv.systemdEnv        -> for systemd service Environment lists
{
  # Core NVIDIA Wayland variables (shared across all contexts)
  core = {
    LIBVA_DRIVER_NAME = "nvidia";
    GBM_BACKEND = "nvidia-drm";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
  };

  # Additional system-level variables
  sessionVariables = {
    LIBVA_DRIVER_NAME = "nvidia";
    GBM_BACKEND = "nvidia-drm";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    XDG_SESSION_TYPE = "wayland";
    WLR_NO_HARDWARE_CURSORS = "1";
  };

  # For Hyprland env format: "NAME,value"
  hyprlandEnv = [
    "LIBVA_DRIVER_NAME,nvidia"
    "GBM_BACKEND,nvidia-drm"
    "__GLX_VENDOR_LIBRARY_NAME,nvidia"
  ];

  # For systemd Environment format: "NAME=value"
  systemdEnv = [
    "LIBVA_DRIVER_NAME=nvidia"
    "GBM_BACKEND=nvidia-drm"
    "__GLX_VENDOR_LIBRARY_NAME=nvidia"
  ];
}
