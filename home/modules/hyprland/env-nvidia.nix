# env-nvidia.nix - NVIDIA-specific environment variables
# Only applied when hostMeta.hasNvidia is true
{ config, lib, pkgs, ... }:
let
  nvidiaEnv = import ../../../lib/nvidia-env.nix;
in
{
  wayland.windowManager.hyprland.settings.env = lib.mkIf config.hostMeta.hasNvidia nvidiaEnv.hyprlandEnv;
}
