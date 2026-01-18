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

    # Keybinds with section headers for cheatsheet
    # This overrides the keybinds defined in keybinds.nix
    ".config/hypr/keybinds-with-sections.conf".text = ''
      # Lines ending with `# [hidden]` won't be shown on cheatsheet
      # Lines starting with ##! are section headings

      # Define modifier variables
      $mod = SUPER
      $modifier = SUPER

      ##! Shell
      bindd = $mod, V, Clipboard history >> clipboard, global, quickshell:overviewClipboardToggle # Clipboard history >> clipboard
      bindd = $mod, Period, Emoji >> clipboard, global, quickshell:overviewEmojiToggle # Emoji >> clipboard
      bindd = $mod, Tab, Toggle overview, global, quickshell:overviewToggle # Toggle overview
      bindd = $mod, A, Toggle left sidebar, global, quickshell:sidebarLeftToggle # Toggle left sidebar
      bindd = $mod, N, Toggle right sidebar, global, quickshell:sidebarRightToggle # Toggle right sidebar
      bindd = $mod, Slash, Toggle cheatsheet, global, quickshell:cheatsheetToggle # Toggle cheatsheet
      bindd = $mod, K, Toggle on-screen keyboard, global, quickshell:oskToggle # Toggle on-screen keyboard
      bindd = $mod, M, Toggle media controls, global, quickshell:mediaControlsToggle # Toggle media controls
      bindd = CTRL+ALT, Delete, Toggle session menu, global, quickshell:sessionToggle # Toggle session menu

      # QuickShell internal bindings
      bind = $mod, mouse:272, global, quickshell:overviewToggleReleaseInterrupt # [hidden]
      bind = $mod, mouse:273, global, quickshell:overviewToggleReleaseInterrupt # [hidden]
      bind = $mod, mouse:274, global, quickshell:overviewToggleReleaseInterrupt # [hidden]
      bind = $mod, mouse:275, global, quickshell:overviewToggleReleaseInterrupt # [hidden]
      bind = $mod, mouse:276, global, quickshell:overviewToggleReleaseInterrupt # [hidden]
      bind = $mod, mouse:277, global, quickshell:overviewToggleReleaseInterrupt # [hidden]
      bind = $mod, mouse_up, global, quickshell:overviewToggleReleaseInterrupt # [hidden]
      bind = $mod, mouse_down, global, quickshell:overviewToggleReleaseInterrupt # [hidden]
      bind = $mod+ALT, A, global, quickshell:sidebarLeftToggleDetach # [hidden]
      bind = $mod, B, global, quickshell:sidebarLeftToggle # [hidden]
      bind = $mod, O, global, quickshell:sidebarLeftToggle # [hidden]
      bindit = , Super_L, global, quickshell:workspaceNumber # [hidden]

      ##! Apps
      bind = $mod, C, exec, ~/.config/hypr/scripts/open_vscode_here.sh # VSCode
      bind = $mod, Return, exec, ~/.config/hypr/scripts/launch_first_available.sh 'kitty' 'kitty -1' 'foot' 'alacritty' 'wezterm' 'konsole' 'kgx' 'uxterm' 'xterm' # Terminal
      bind = $mod, T, exec, ~/.config/hypr/scripts/open_terminal_here.sh # Terminal here
      bind = $mod, W, exec, ~/.config/hypr/scripts/launch_first_available.sh 'firefox' 'zen-browser' 'firefox' 'brave' 'chromium' 'google-chrome-stable' 'microsoft-edge-stable' 'opera' # Browser
      bind = $mod+CONTROL, F, exec, ~/.config/hypr/hyprland/scripts/launch_first_available.sh 'yazi' 'dolphin' 'nautilus' 'nemo' 'thunar' # File manager
      bind = $mod, Space, exec, pkill -x rofi || rofi -show drun # Launcher

      ##! Window
      bindm = $mod, mouse:272, movewindow # Move
      bindm = $mod, mouse:273, resizewindow # Resize
      bind = $mod, Left, movefocus, l # [hidden]
      bind = $mod, Right, movefocus, r # [hidden]
      bind = $mod, Up, movefocus, u # [hidden]
      bind = $mod, Down, movefocus, d # [hidden]
      bind = $mod, bracketleft, movefocus, l # [hidden]
      bind = $mod, bracketright, movefocus, r # [hidden]
      bind = $mod, Q, killactive, # Close
      bind = $mod SHIFT, Left, movewindow, l # [hidden]
      bind = $mod SHIFT, Right, movewindow, r # [hidden]
      bind = $mod SHIFT, Up, movewindow, u # [hidden]
      bind = $mod SHIFT, Down, movewindow, d # [hidden]
      bind = $mod SHIFT, Space, togglefloating, # Float/Tile
      bind = $mod, F, fullscreen, 0 # Fullscreen
      bind = $mod, D, fullscreen, 1 # Maximize
      bind = $mod, P, pin # Pin

      ##! Workspace
      bind = $mod, 1, workspace, 1 # [hidden]
      bind = $mod, 2, workspace, 2 # [hidden]
      bind = $mod, 3, workspace, 3 # [hidden]
      bind = $mod, 4, workspace, 4 # [hidden]
      bind = $mod, 5, workspace, 5 # [hidden]
      bind = $mod, 6, workspace, 6 # [hidden]
      bind = $mod, 7, workspace, 7 # [hidden]
      bind = $mod, 8, workspace, 8 # [hidden]
      bind = $mod, 9, workspace, 9 # [hidden]
      bind = $mod, 0, workspace, 10 # [hidden]
      bind = $mod, mouse_up, workspace, +1 # [hidden]
      bind = $mod, mouse_down, workspace, -1 # [hidden]
      bind = $mod CONTROL, Right, workspace, r+1 # [hidden]
      bind = $mod CONTROL, Left, workspace, r-1 # [hidden]
      bind = $mod, Page_Down, workspace, +1 # [hidden]
      bind = $mod, Page_Up, workspace, -1 # [hidden]
      bind = $mod CONTROL, Page_Down, workspace, r+1 # [hidden]
      bind = $mod CONTROL, Page_Up, workspace, r-1 # [hidden]
      bind = $mod, S, togglespecialworkspace, # Toggle scratchpad

      bind = $mod ALT, 1, movetoworkspacesilent, 1 # [hidden]
      bind = $mod ALT, 2, movetoworkspacesilent, 2 # [hidden]
      bind = $mod ALT, 3, movetoworkspacesilent, 3 # [hidden]
      bind = $mod ALT, 4, movetoworkspacesilent, 4 # [hidden]
      bind = $mod ALT, 5, movetoworkspacesilent, 5 # [hidden]
      bind = $mod ALT, 6, movetoworkspacesilent, 6 # [hidden]
      bind = $mod ALT, 7, movetoworkspacesilent, 7 # [hidden]
      bind = $mod ALT, 8, movetoworkspacesilent, 8 # [hidden]
      bind = $mod ALT, 9, movetoworkspacesilent, 9 # [hidden]
      bind = $mod ALT, 0, movetoworkspacesilent, 10 # [hidden]
      bind = $mod ALT, S, movetoworkspacesilent, special # [hidden]

      bind = ALT, Tab, cyclenext, # [hidden]
      bind = ALT, Tab, bringactivetotop, # [hidden]

      ##! Session
      bind = $modifier,L,exec,loginctl lock-session # Lock
      bind = $modifier SHIFT,L,exec,loginctl lock-session # [hidden]

      ##! Media
      bind = , XF86AudioPlay, exec, playerctl play-pause # [hidden]
      bind = , XF86AudioNext, exec, playerctl next # [hidden]
      bind = , XF86AudioPrev, exec, playerctl previous # [hidden]

      binde = $mod, minus, splitratio, -0.1 # [hidden]
      binde = $mod, equal, splitratio, +0.1 # [hidden]
      binde = $mod, semicolon, splitratio, -0.1 # [hidden]
      binde = $mod, apostrophe, splitratio, +0.1 # [hidden]
      binde = , XF86AudioRaiseVolume, exec, wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+ # [hidden]
      binde = , XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%- # [hidden]

      bindl = , XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle # [hidden]
      bindl = $mod, XF86AudioMute, exec, wpctl set-mute @DEFAULT_SOURCE@ toggle # [hidden]
      bindl = , switch:on:Lid Switch, exec, hyprctl keyword monitor 'eDP-1,disable' # [hidden]
      bindl = , switch:off:Lid Switch, exec, hyprctl keyword monitor 'eDP-1,preferred,auto,1' # [hidden]

      bindr = $mod CONTROL ALT, R, exec, hyprctl reload # [hidden]
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
      source = ~/.config/hypr/keybinds-with-sections.conf
    '';
  };

  xdg.userDirs = {
    enable = true;
    createDirectories = true;
  };
  
}