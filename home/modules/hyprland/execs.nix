# hyprland-execs.nix
{ config, lib, pkgs, username, ... }:
let
  inherit (import ../../users/${username}/variables.nix) wallpaper;
in
{
  wayland.windowManager.hyprland.settings = {
    exec-once = [
      # Clipboard history
      "wl-paste --type text --watch cliphist store"
      "wl-paste --type image --watch cliphist store"
      # Environment setup
      "dbus-update-activation-environment --all --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
      "systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
      # Set default wallpaper via Quickshell (wait for Quickshell to start)
      "sleep 2 && ~/.config/quickshell/default/scripts/colors/switchwall.sh ${config.home.homeDirectory}/${wallpaper}"
      "hypridle"
    ];
  };
}
