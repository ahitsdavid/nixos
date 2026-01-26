# env-nvidia.nix - NVIDIA-specific environment variables (added to env.nix)
{ config, lib, pkgs, ... }:

{
  wayland.windowManager.hyprland.settings.env = [
    "LIBVA_DRIVER_NAME,nvidia"
    "GBM_BACKEND,nvidia-drm"
    "__GLX_VENDOR_LIBRARY_NAME,nvidia"
  ];
}
