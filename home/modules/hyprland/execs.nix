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
      
      "killall -q swww;sleep .5 && swww-daemon"
      "sleep 1.5 && swww img ${config.home.homeDirectory}/${wallpaper}"
      # AGS (Aylur's GTK Shell)
      #"ags run --gtk4 &" 
    ];
  };
}
