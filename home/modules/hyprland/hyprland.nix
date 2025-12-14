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

    # Generate separate config files from Nix
    ".config/hypr/rules.conf".text = ''
      # Window rules - Updated for Hyprland 0.52.0+
      # Opacity rules now require three values: inactive, active, fullscreen
      windowrulev2 = opacity 0.8 0.8 1, class:^(code)$
      windowrulev2 = opacity 0.8 0.8 1, class:^([Cc]ode)$
      windowrulev2 = opacity 0.8 0.8 1, class:^(code-url-handler)$
      windowrulev2 = opacity 0.80 0.80 1, class:^(vesktop)$
      windowrulev2 = opacity 0.80 0.80 1, class:^(discord)$
      windowrulev2 = opacity 0.80 0.80 1, class:^(WebCord)$
      windowrulev2 = opacity 0.80 0.80 1, class:^(ArmCord)$

      # Floating rules - converted to windowrulev2 for better compatibility
      windowrulev2 = float, class:^(org.kde.dolphin)$, title:^(Progress Dialog — Dolphin)$
      windowrulev2 = float, class:^(org.kde.dolphin)$, title:^(Copying — Dolphin)$
      windowrulev2 = float, title:^(About Mozilla Firefox)$
      windowrulev2 = float, class:^(firefox)$, title:^(Picture-in-Picture)$
      windowrulev2 = float, class:^(firefox)$, title:^(Library)$
      windowrulev2 = float, class:^(kitty)$, title:^(top)$
      windowrulev2 = float, class:^(kitty)$, title:^(btop)$
      windowrulev2 = float, class:^(kitty)$, title:^(htop)$
      windowrulev2 = float, class:^(vlc)$
      windowrulev2 = float, class:^(kvantummanager)$
      windowrulev2 = float, class:^(qt5ct)$
      windowrulev2 = float, class:^(qt6ct)$
      windowrulev2 = float, class:^(nwg-look)$
      windowrulev2 = float, class:^(org.kde.ark)$
      windowrulev2 = float, class:^(org.pulseaudio.pavucontrol)$
      windowrulev2 = float, class:^(blueman-manager)$
      windowrulev2 = float, class:^(nm-applet)$
      windowrulev2 = float, class:^(nm-connection-editor)$
      windowrulev2 = float, class:^(org.kde.polkit-kde-authentication-agent-1)$
      windowrulev2 = float, class:^(Signal)$
      windowrulev2 = float, class:^(com.github.rafostar.Clapper)$
      windowrulev2 = float, class:^(app.drey.Warp)$
      windowrulev2 = float, class:^(net.davidotek.pupgui2)$
      windowrulev2 = float, class:^(yad)$
      windowrulev2 = float, class:^(eog)$
      windowrulev2 = float, class:^(io.github.alainm23.planify)$
      windowrulev2 = float, class:^(io.gitlab.theevilskeleton.Upscaler)$
      windowrulev2 = float, class:^(com.github.unrud.VideoDownloader)$
      windowrulev2 = float, class:^(io.gitlab.adhami3310.Impression)$
      windowrulev2 = float, class:^(io.missioncenter.MissionCenter)$

      # Common modals
      windowrulev2 = float, title:^(Open)$
      windowrulev2 = float, title:^(Authentication Required)$
      windowrulev2 = float, title:^(Add Folder to Workspace)$
      windowrulev2 = float, title:^(Open File)$
      windowrulev2 = float, title:^(Choose Files)$
      windowrulev2 = float, title:^(Save As)$
      windowrulev2 = float, title:^(Confirm to replace files)$
      windowrulev2 = float, title:^(File Operation Progress)$
      windowrulev2 = float, class:^([Xx]dg-desktop-portal-gtk)$
      windowrulev2 = float, title:^(File Upload)(.*)$
      windowrulev2 = float, title:^(Choose wallpaper)(.*)$
      windowrulev2 = float, title:^(Library)(.*)$
      windowrulev2 = float, class:^(.*dialog.*)$
      windowrulev2 = float, title:^(.*dialog.*)$
      
      # Window rules v2
      windowrulev2 = noblur, xwayland:1
      windowrulev2 = float, class:^(blueberry\.py)$
      windowrulev2 = float, class:^(steam)$
      windowrulev2 = float, class:^(guifetch)$
      windowrulev2 = float, class:^(pavucontrol)$
      windowrulev2 = size 45%, class:^(pavucontrol)$
      windowrulev2 = center, class:^(pavucontrol)$
      windowrulev2 = float, class:^(org.pulseaudio.pavucontrol)$
      windowrulev2 = size 45%, class:^(org.pulseaudio.pavucontrol)$
      windowrulev2 = center, class:^(org.pulseaudio.pavucontrol)$
      windowrulev2 = float, class:^(nm-connection-editor)$
      windowrulev2 = size 45%, class:^(nm-connection-editor)$
      windowrulev2 = center, class:^(nm-connection-editor)$
      windowrulev2 = float, title:^([Pp]icture[-\\s]?[Ii]n[-\\s]?[Pp]icture)(.*)$
      windowrulev2 = keepaspectratio, title:^([Pp]icture[-\\s]?[Ii]n[-\\s]?[Pp]icture)(.*)$
      windowrulev2 = move 73% 72%, title:^([Pp]icture[-\\s]?[Ii]n[-\\s]?[Pp]icture)(.*)$
      windowrulev2 = size 25%, title:^([Pp]icture[-\\s]?[Ii]n[-\\s]?[Pp]icture)(.*)$
      windowrulev2 = pin, title:^([Pp]icture[-\\s]?[Ii]n[-\\s]?[Pp]icture)(.*)$
      windowrulev2 = center, title:^(Open File)(.*)$
      windowrulev2 = center, title:^(Select a File)(.*)$
      windowrulev2 = center, title:^(Choose wallpaper)(.*)$
      windowrulev2 = center, title:^(Open Folder)(.*)$
      windowrulev2 = center, title:^(Save As)(.*)$
      windowrulev2 = center, title:^(Library)(.*)$
      windowrulev2 = center, title:^(File Upload)(.*)$
      windowrulev2 = float, title:^(Open File)(.*)$
      windowrulev2 = float, title:^(Select a File)(.*)$
      windowrulev2 = float, title:^(Choose wallpaper)(.*)$
      windowrulev2 = float, title:^(Open Folder)(.*)$
      windowrulev2 = float, title:^(Save As)(.*)$
      windowrulev2 = float, title:^(Library)(.*)$
      windowrulev2 = float, title:^(File Upload)(.*)$
      windowrulev2 = immediate, title:.*\.exe
      windowrulev2 = immediate, class:^(steam_app)
      windowrulev2 = noshadow, floating:0
      
      # Workspace rules
      workspace = special:special, gapsout:30

      # NOTE: Layer rules have been moved to rules.nix to avoid parsing errors.
      # Text-based layerrule directives in sourced config files cause syntax
      # errors in Hyprland 0.52.0+. Use the Nix settings format in rules.nix instead.
    '';
    
    ".config/hypr/env.conf".text = ''
      # Environment variables
      env = NIXOS_OZONE_WL, 1
      env = NIXPKGS_ALLOW_UNFREE, 1
      env = XDG_SESSION_TYPE, wayland
      env = XDG_SESSION_DESKTOP, Hyprland
      env = XDG_CURRENT_DESKTOP, Hyprland
      env = GDK_BACKEND, wayland, x11
      env = CLUTTER_BACKEND, wayland
      env = QT_QPA_PLATFORM=wayland;xcb
      env = QT_WAYLAND_DISABLE_WINDOWDECORATION, 1
      env = QT_AUTO_SCREEN_SCALE_FACTOR, 1
      env = SDL_VIDEODRIVER, x11
      env = MOZ_ENABLE_WAYLAND, 1
      env = GDK_SCALE,1
      env = QT_SCALE_FACTOR,1
      env = QT_IM_MODULE, fcitx
      env = XMODIFIERS, @im=fcitx
      env = SDL_IM_MODULE, fcitx
      env = GLFW_IM_MODULE, ibus
      env = INPUT_METHOD, fcitx
      env = QT_QPA_PLATFORM, wayland
      env = QT_QPA_PLATFORMTHEME, gtk3
      env = QT_STYLE_OVERRIDE, 
      env = WLR_NO_HARDWARE_CURSORS, 1
      env = HYPRCURSOR_THEME, rose-pine-hyprcursor
      env = HYPRCURSOR_SIZE, 40
      env = XCURSOR_THEME, rose-pine-hyprcursor
      env = XCURSOR_SIZE, 40
      env = EDITOR, nvim
      env = BROWSER, firefox
      env = TERMINAL, kitty
      env = XDG_TERMINAL_EMULATOR,kitty
      env = QML2_IMPORT_PATH, qmlImportPath
      env = LIBVIRT_DEFAULT_URI, qemu:///system
      env = ELECTRON_OZONE_PLATFORM_HINT, wayland
    '';
    
    
    ".config/hypr/exec.conf".text = ''
      # Startup applications
      exec-once = wl-paste --type text --watch cliphist store
      exec-once = wl-paste --type image --watch cliphist store
      exec-once = dbus-update-activation-environment --all --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP
      exec-once = systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP
      exec-once = swww-daemon --format xrgb --no-cache
      exec-once = sleep 0.5 && swww img ~/Pictures/wallpapers/default.jpg
      exec-once = hypridle
    '';
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
    
    extraConfig = ''
      # Source additional configuration files
      source = ~/.config/hypr/rules.conf
      source = ~/.config/hypr/env.conf
      source = ~/.config/hypr/exec.conf
    '';
  };

  xdg.userDirs = {
    enable = true;
    createDirectories = true;
  };
  
}