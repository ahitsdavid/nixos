# hyprland.nix
{inputs, pkgs, config, lib, ... }:
{
  home.packages = with pkgs; [
      cava
      swww
      wl-clipboard
      brightnessctl
      fuzzel
      grimblast
      hyprland-qt-support
      hyprland-qtutils
      hyprlang
      hyprshot
      hyprpicker
      hyprwayland-scanner
      networkmanagerapplet
      nwg-displays
      slurp
      swappy
      tesseract
      wf-recorder

      #Quickshell
      translate-shell
  ];
  
  home.file = {
    ".config/hypr/scripts" = {
      source = ./scripts;
      recursive = true;
    };
  };

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

  xdg.userDirs = {
    enable = true;
    createDirectories = true;
  };
  
}