# env-nvidia.nix - NVIDIA-specific environment variables
# Only applied when hostMeta.hasNvidia is true
{ config, lib, pkgs, ... }:

{
  wayland.windowManager.hyprland.settings.env = lib.mkIf config.hostMeta.hasNvidia [
    "LIBVA_DRIVER_NAME,nvidia"
    "GBM_BACKEND,nvidia-drm"
    "__GLX_VENDOR_LIBRARY_NAME,nvidia"
  ];
}
