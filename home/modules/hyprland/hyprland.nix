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
    ".config/hypr/scripts/launch_first_available.sh" = {
      source = ./scripts/launch_first_available.sh;
      executable = true;
    };
    ".config/hypr/scripts/open_terminal_here.sh" = {
      source = ./scripts/open_terminal_here.sh;
      executable = true;
    };
    ".config/hypr/scripts/open_vscode_here.sh" = {
      source = ./scripts/open_vscode_here.sh;
      executable = true;
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