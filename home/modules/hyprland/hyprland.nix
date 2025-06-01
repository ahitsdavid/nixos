# hyprland.nix
{inputs, pkgs, config, lib, ... }:
{
  home.packages = with pkgs; [
      swww
      wl-clipboard
      brightnessctl
      grimblast
      hyprpicker
  ];
  
  wayland.windowManager.hyprland = {
    enable = true;
    package = inputs.hyprland.packages.${pkgs.system}.hyprland;
    systemd = {
      enable = true;
      enableXdgAutostart = true;
      variables = ["--all"];
    };
    
    xwayland = {
      enable = true;
    };
  };
}