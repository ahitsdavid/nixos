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
      # Window rules
      windowrule = opacity 0.8 0.8, class:^(code)$
      windowrule = opacity 0.8 0.8, class:^([Cc]ode)$
      windowrule = opacity 0.8 0.8, class:^(code-url-handler)$
      windowrule = opacity 0.80 0.80, class:^(vesktop)$
      windowrule = opacity 0.80 0.80, class:^(discord)$
      windowrule = opacity 0.80 0.80, class:^(WebCord)$
      windowrule = opacity 0.80 0.80, class:^(ArmCord)$
      
      # Floating rules
      windowrule = float, class:^(org.kde.dolphin)$, title:^(Progress Dialog — Dolphin)$
      windowrule = float, class:^(org.kde.dolphin)$, title:^(Copying — Dolphin)$
      windowrule = float, title:^(About Mozilla Firefox)$
      windowrule = float, class:^(firefox)$, title:^(Picture-in-Picture)$
      windowrule = float, class:^(firefox)$, title:^(Library)$
      windowrule = float, class:^(kitty)$, title:^(top)$
      windowrule = float, class:^(kitty)$, title:^(btop)$
      windowrule = float, class:^(kitty)$, title:^(htop)$
      windowrule = float, class:^(vlc)$
      windowrule = float, class:^(kvantummanager)$
      windowrule = float, class:^(qt5ct)$
      windowrule = float, class:^(qt6ct)$
      windowrule = float, class:^(nwg-look)$
      windowrule = float, class:^(org.kde.ark)$
      windowrule = float, class:^(org.pulseaudio.pavucontrol)$
      windowrule = float, class:^(blueman-manager)$
      windowrule = float, class:^(nm-applet)$
      windowrule = float, class:^(nm-connection-editor)$
      windowrule = float, class:^(org.kde.polkit-kde-authentication-agent-1)$
      windowrule = float, class:^(Signal)$
      windowrule = float, class:^(com.github.rafostar.Clapper)$
      windowrule = float, class:^(app.drey.Warp)$
      windowrule = float, class:^(net.davidotek.pupgui2)$
      windowrule = float, class:^(yad)$
      windowrule = float, class:^(eog)$
      windowrule = float, class:^(io.github.alainm23.planify)$
      windowrule = float, class:^(io.gitlab.theevilskeleton.Upscaler)$
      windowrule = float, class:^(com.github.unrud.VideoDownloader)$
      windowrule = float, class:^(io.gitlab.adhami3310.Impression)$
      windowrule = float, class:^(io.missioncenter.MissionCenter)$
      
      # Common modals
      windowrule = float, title:^(Open)$
      windowrule = float, title:^(Authentication Required)$
      windowrule = float, title:^(Add Folder to Workspace)$
      windowrule = float, title:^(Open File)$
      windowrule = float, title:^(Choose Files)$
      windowrule = float, title:^(Save As)$
      windowrule = float, title:^(Confirm to replace files)$
      windowrule = float, title:^(File Operation Progress)$
      windowrule = float, class:^([Xx]dg-desktop-portal-gtk)$
      windowrule = float, title:^(File Upload)(.*)$
      windowrule = float, title:^(Choose wallpaper)(.*)$
      windowrule = float, title:^(Library)(.*)$
      windowrule = float, class:^(.*dialog.*)$
      windowrule = float, title:^(.*dialog.*)$
      
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
      windowrulev2 = float, title:^([Pp]icture[-\\s]?[Ii]n[-\\s]?[Pp]icture)(.*)$
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
      
      # Layer rules
      layerrule = xray 1, .*
      layerrule = noanim, walker
      layerrule = noanim, selection
      layerrule = noanim, overview
      layerrule = noanim, anyrun
      layerrule = noanim, indicator.*
      layerrule = noanim, osk
      layerrule = noanim, hyprpicker
      layerrule = noanim, noanim
      layerrule = blur, gtk-layer-shell
      layerrule = ignorezero, gtk-layer-shell
      layerrule = blur, launcher
      layerrule = ignorealpha 0.5, launcher
      layerrule = blur, notifications
      layerrule = ignorealpha 0.69, notifications
      layerrule = blur, logout_dialog
      layerrule = animation slide left, sideleft.*
      layerrule = animation slide right, sideright.*
      layerrule = blur, session[0-9]*
      layerrule = blur, bar[0-9]*
      layerrule = ignorealpha 0.6, bar[0-9]*
      layerrule = blur, barcorner.*
      layerrule = ignorealpha 0.6, barcorner.*
      layerrule = blur, dock[0-9]*
      layerrule = ignorealpha 0.6, dock[0-9]*
      layerrule = blur, indicator.*
      layerrule = ignorealpha 0.6, indicator.*
      layerrule = blur, overview[0-9]*
      layerrule = ignorealpha 0.6, overview[0-9]*
      layerrule = blur, cheatsheet[0-9]*
      layerrule = ignorealpha 0.6, cheatsheet[0-9]*
      layerrule = blur, sideright[0-9]*
      layerrule = ignorealpha 0.6, sideright[0-9]*
      layerrule = blur, sideleft[0-9]*
      layerrule = ignorealpha 0.6, sideleft[0-9]*
      layerrule = blur, indicator.*
      layerrule = ignorealpha 0.6, indicator.*
      layerrule = blur, osk[0-9]*
      layerrule = ignorealpha 0.6, osk[0-9]*
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
    package = inputs.hyprland.packages.${pkgs.system}.hyprland;
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