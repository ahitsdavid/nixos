# hyprland.nix
{inputs, pkgs, config, lib, ... }:
{
  home.packages = with pkgs; [
      bc
      cava
      swww
      wl-clipboard
      brightnessctl
      cliphist
      fuzzel
      grim
      grimblast
      hyprland-qt-support
      hyprland-qtutils
      hyprlang
      hyprshot
      hyprpicker
      hyprwayland-scanner
      jq
      networkmanagerapplet
      nwg-displays
      playerctl
      slurp
      swappy
      tesseract
      wf-recorder
      wlogout

      #Quickshell
      translate-shell
      xdg-user-dirs
      zenity
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
    ".config/hypr/scripts/super_launcher.sh" = {
      source = ./scripts/super_launcher.sh;
      executable = true;
    };
    ".config/hypr/scripts/zoom.sh" = {
      source = ./scripts/zoom.sh;
      executable = true;
    };
  };

  wayland.windowManager.hyprland = {
    enable = true;
    package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
    systemd = {
      enable = true;
      enableXdgAutostart = true;
      variables = ["--all"];
    };

    xwayland = {
      enable = true;
    };

    # env is in env.nix / env-nvidia.nix
    # exec-once is in execs.nix
    # Window rules, workspace rules, and layer rules are in rules.nix
  };

  xdg.userDirs = {
    enable = true;
    createDirectories = true;
  };
  
}
