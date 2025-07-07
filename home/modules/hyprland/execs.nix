# hyprland-execs.nix
{ config, lib, pkgs, username, ... }:
let
  inherit
    (import ../../users/${username}/variables.nix)
    wallpaper
    ;
in 
{
  wayland.windowManager.hyprland.settings = {
    exec-once = [
      # Wayland wallpaper 
      "wl-paste --type text --watch cliphist store"
      "wl-paste --type image --watch cliphist store"
      "dbus-update-activation-environment --all --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
      "systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
      "swww-daemon --format xrgb --no-cache"
      "sleep 0.5 && swww img ${config.home.homeDirectory}/${wallpaper}"
      "hypridle"
    ];
  };
}
