{ host, username, lib, ... }:
let
  inherit
    (import ../../users/${username}/variables.nix)
    browser
    terminal
    file-manager
    ;

  # Keybind configuration content - shared between the conf file and extraConfig
  keybindContent = ''
    # Define modifier variables
    $mod = SUPER
    $modifier = SUPER

    ##! Shell
    bind = $mod, Tab, global, quickshell:overviewWorkspacesToggle # Toggle overview
    bindd = $mod, V, Clipboard history >> clipboard, global, quickshell:overviewClipboardToggle # Clipboard history >> clipboard
    bindd = $mod, Period, Emoji >> clipboard, global, quickshell:overviewEmojiToggle # Emoji >> clipboard
    bind = $mod, A, global, quickshell:sidebarLeftToggle # Toggle left sidebar
    bind = $mod+ALT, A, global, quickshell:sidebarLeftToggleDetach # [hidden]
    bind = $mod, B, global, quickshell:sidebarLeftToggle # [hidden]
    bind = $mod, O, global, quickshell:sidebarLeftToggle # [hidden]
    bindd = $mod, N, Toggle right sidebar, global, quickshell:sidebarRightToggle # Toggle right sidebar
    bindd = $mod, Slash, Toggle cheatsheet, global, quickshell:cheatsheetToggle # Toggle cheatsheet
    bindd = $mod, K, Toggle on-screen keyboard, global, quickshell:oskToggle # Toggle on-screen keyboard
    bindd = $mod, M, Toggle media controls, global, quickshell:mediaControlsToggle # Toggle media controls
    bind = $mod, G, global, quickshell:overlayToggle # Toggle overlay
    bindd = CTRL+ALT, Delete, Toggle session menu, global, quickshell:sessionToggle # Toggle session menu
    bindd = $mod, J, Toggle bar, global, quickshell:barToggle # Toggle bar
    bind = CTRL+$mod, R, exec, killall ags agsv1 gjs ydotool qs quickshell; qs & # Restart widgets
    bind = CTRL+$mod, P, global, quickshell:panelFamilyCycle # Cycle panel family

    ##! Utilities
    # Screenshot, Record, OCR, Color picker
    bind = $mod+SHIFT, S, global, quickshell:regionScreenshot # Screen snip
    bind = $mod+SHIFT, A, global, quickshell:regionSearch # Google Lens
    bind = $mod+SHIFT, X, global, quickshell:regionOcr # Character recognition >> clipboard
    bindd = $mod+SHIFT, C, Color picker, exec, hyprpicker -a # Pick color (Hex) >> clipboard
    bindl = , Print, exec, grim - | wl-copy # Screenshot >> clipboard
    # Recording
    bindl = $mod+SHIFT, R, global, quickshell:regionRecord # Record region (no sound)
    bindl = CTRL+ALT, R, exec, ~/.config/quickshell/scripts/videos/record.sh --fullscreen # Record screen (no sound)
    bindl = $mod+SHIFT+ALT, R, exec, ~/.config/quickshell/scripts/videos/record.sh --fullscreen --sound # Record screen (with sound)
    # Wallpaper
    bindd = CTRL+$mod, T, Toggle wallpaper selector, global, quickshell:wallpaperSelectorToggle # Wallpaper selector
    bindd = CTRL+$mod+ALT, T, Select random wallpaper, global, quickshell:wallpaperSelectorRandom # Random wallpaper

    ##! Apps
    bind = $mod, Return, exec, ~/.config/hypr/scripts/launch_first_available.sh '${terminal}' 'kitty -1' 'foot' 'alacritty' 'wezterm' 'konsole' 'kgx' 'uxterm' 'xterm' # Terminal
    bind = $mod, T, exec, ~/.config/hypr/scripts/launch_first_available.sh '${terminal}' 'kitty -1' 'foot' 'alacritty' 'wezterm' 'konsole' 'kgx' 'uxterm' 'xterm' # [hidden] (terminal alt)
    bind = CTRL+ALT, T, exec, ~/.config/hypr/scripts/launch_first_available.sh '${terminal}' 'kitty -1' 'foot' 'alacritty' 'wezterm' 'konsole' 'kgx' 'uxterm' 'xterm' # [hidden] (terminal Ubuntu)
    bind = $mod, E, exec, ~/.config/hypr/scripts/launch_first_available.sh '${file-manager}' 'dolphin' 'nautilus' 'nemo' 'thunar' # File manager
    bind = $mod, W, exec, ~/.config/hypr/scripts/launch_first_available.sh '${browser}' 'zen-browser' 'firefox' 'brave' 'chromium' 'google-chrome-stable' 'microsoft-edge-stable' 'opera' 'librewolf' # Browser
    bind = $mod, C, exec, ~/.config/hypr/scripts/launch_first_available.sh 'code' 'codium' 'cursor' 'zed' 'kate' 'gnome-text-editor' 'emacs' # Code editor
    bind = CTRL+$mod+SHIFT+ALT, W, exec, ~/.config/hypr/scripts/launch_first_available.sh 'wps' 'onlyoffice-desktopeditors' 'libreoffice' # Office software
    bind = $mod, X, exec, ~/.config/hypr/scripts/launch_first_available.sh 'kate' 'gnome-text-editor' 'emacs' # Text editor
    bind = CTRL+$mod, V, exec, ~/.config/hypr/scripts/launch_first_available.sh 'pavucontrol-qt' 'pavucontrol' # Volume mixer
    bind = $mod, I, exec, XDG_CURRENT_DESKTOP=gnome ~/.config/hypr/scripts/launch_first_available.sh 'systemsettings' 'gnome-control-center' 'better-control' # Settings app
    bind = CTRL+SHIFT, Escape, exec, ~/.config/hypr/scripts/launch_first_available.sh 'gnome-system-monitor' 'plasma-systemmonitor --page-name Processes' # Task manager
    bind = $mod, Space, exec, pkill -x rofi || rofi -show drun # Launcher (rofi)

    ##! Window
    bindm = $mod, mouse:272, movewindow # Move
    bindm = $mod, mouse:274, movewindow # [hidden]
    bindm = $mod, mouse:273, resizewindow # Resize
    bind = $mod, Left, movefocus, l # [hidden]
    bind = $mod, Right, movefocus, r # [hidden]
    bind = $mod, Up, movefocus, u # [hidden]
    bind = $mod, Down, movefocus, d # [hidden]
    bind = $mod, BracketLeft, movefocus, l # [hidden]
    bind = $mod, BracketRight, movefocus, r # [hidden]
    bind = $mod+SHIFT, Left, movewindow, l # [hidden]
    bind = $mod+SHIFT, Right, movewindow, r # [hidden]
    bind = $mod+SHIFT, Up, movewindow, u # [hidden]
    bind = $mod+SHIFT, Down, movewindow, d # [hidden]
    bind = ALT, F4, killactive, # [hidden] Close (Windows)
    bind = $mod, Q, killactive, # Close
    bind = $mod+SHIFT+ALT, Q, exec, hyprctl kill # Forcefully zap a window
    # Window split ratio
    binde = $mod, Semicolon, splitratio, -0.1 # [hidden]
    binde = $mod, Apostrophe, splitratio, +0.1 # [hidden]
    # Positioning mode
    bind = $mod+ALT, Space, togglefloating, # Float/Tile
    bind = $mod+SHIFT, Space, togglefloating, # [hidden] Float/Tile (alt)
    bind = $mod, D, fullscreen, 1 # Maximize
    bind = $mod, F, fullscreen, 0 # Fullscreen
    bind = $mod+ALT, F, fullscreenstate, 0 3 # Fullscreen spoof
    bind = $mod, P, pin # Pin

    ##! Workspace
    # Focus workspace by number
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
    # Navigation
    bind = CTRL+$mod, Right, workspace, r+1 # [hidden]
    bind = CTRL+$mod, Left, workspace, r-1 # [hidden]
    bind = CTRL+$mod+ALT, Right, workspace, m+1 # [hidden]
    bind = CTRL+$mod+ALT, Left, workspace, m-1 # [hidden]
    bind = $mod, Page_Down, workspace, +1 # [hidden]
    bind = $mod, Page_Up, workspace, -1 # [hidden]
    bind = CTRL+$mod, Page_Down, workspace, r+1 # [hidden]
    bind = CTRL+$mod, Page_Up, workspace, r-1 # [hidden]
    bind = $mod, mouse_up, workspace, +1 # [hidden]
    bind = $mod, mouse_down, workspace, -1 # [hidden]
    bind = CTRL+$mod, mouse_up, workspace, r+1 # [hidden]
    bind = CTRL+$mod, mouse_down, workspace, r-1 # [hidden]
    bind = CTRL+$mod, BracketLeft, workspace, -1 # [hidden]
    bind = CTRL+$mod, BracketRight, workspace, +1 # [hidden]
    bind = CTRL+$mod, Up, workspace, r-5 # [hidden]
    bind = CTRL+$mod, Down, workspace, r+5 # [hidden]
    # Special workspace (scratchpad)
    bind = $mod, S, togglespecialworkspace, # Toggle scratchpad
    bind = $mod, mouse:275, togglespecialworkspace, # [hidden]
    bind = CTRL+$mod, S, togglespecialworkspace, # [hidden]
    # Send to workspace by number
    bind = $mod+ALT, 1, movetoworkspacesilent, 1 # [hidden]
    bind = $mod+ALT, 2, movetoworkspacesilent, 2 # [hidden]
    bind = $mod+ALT, 3, movetoworkspacesilent, 3 # [hidden]
    bind = $mod+ALT, 4, movetoworkspacesilent, 4 # [hidden]
    bind = $mod+ALT, 5, movetoworkspacesilent, 5 # [hidden]
    bind = $mod+ALT, 6, movetoworkspacesilent, 6 # [hidden]
    bind = $mod+ALT, 7, movetoworkspacesilent, 7 # [hidden]
    bind = $mod+ALT, 8, movetoworkspacesilent, 8 # [hidden]
    bind = $mod+ALT, 9, movetoworkspacesilent, 9 # [hidden]
    bind = $mod+ALT, 0, movetoworkspacesilent, 10 # [hidden]
    bind = $mod+ALT, S, movetoworkspacesilent, special # Send to scratchpad
    # Move to workspace navigation
    bind = $mod+SHIFT, mouse_down, movetoworkspace, r-1 # [hidden]
    bind = $mod+SHIFT, mouse_up, movetoworkspace, r+1 # [hidden]
    bind = $mod+ALT, mouse_down, movetoworkspace, -1 # [hidden]
    bind = $mod+ALT, mouse_up, movetoworkspace, +1 # [hidden]
    bind = $mod+ALT, Page_Down, movetoworkspace, +1 # [hidden]
    bind = $mod+ALT, Page_Up, movetoworkspace, -1 # [hidden]
    bind = $mod+SHIFT, Page_Down, movetoworkspace, r+1 # [hidden]
    bind = $mod+SHIFT, Page_Up, movetoworkspace, r-1 # [hidden]
    bind = CTRL+$mod+SHIFT, Right, movetoworkspace, r+1 # [hidden]
    bind = CTRL+$mod+SHIFT, Left, movetoworkspace, r-1 # [hidden]
    # Alt-Tab
    bind = ALT, Tab, cyclenext, # [hidden]
    bind = ALT, Tab, bringactivetotop, # [hidden]

    ##! Virtual machines
    bind = $mod+ALT, F1, exec, notify-send 'Entered Virtual Machine submap' 'Keybinds disabled. Hit Super+Alt+F1 to escape' -a 'Hyprland' && hyprctl dispatch submap virtual-machine # Disable keybinds
    submap = virtual-machine
    bind = $mod+ALT, F1, exec, notify-send 'Exited Virtual Machine submap' 'Keybinds re-enabled' -a 'Hyprland' && hyprctl dispatch submap global # [hidden]
    submap = global

    ##! Session
    bind = $mod, L, exec, loginctl lock-session # Lock
    bindl = $mod+SHIFT, L, exec, systemctl suspend || loginctl suspend # Sleep

    ##! Screen
    # Zoom
    binde = $mod, Minus, splitratio, -0.1 # [hidden]
    binde = $mod, Equal, splitratio, +0.1 # [hidden]

    ##! Media
    bindl = $mod+SHIFT, N, exec, playerctl next || playerctl position `bc <<< "100 * $(playerctl metadata mpris:length) / 1000000 / 100"` # Next track
    bindl = , XF86AudioNext, exec, playerctl next || playerctl position `bc <<< "100 * $(playerctl metadata mpris:length) / 1000000 / 100"` # [hidden]
    bindl = , XF86AudioPrev, exec, playerctl previous # [hidden]
    bindl = $mod+SHIFT, B, exec, playerctl previous # Previous track
    bindl = $mod+SHIFT, P, exec, playerctl play-pause # Play/pause media
    bindl = , XF86AudioPlay, exec, playerctl play-pause # [hidden]
    bindl = , XF86AudioPause, exec, playerctl play-pause # [hidden]
    # Volume
    binde = , XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+ -l 1.5 # [hidden]
    binde = , XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%- # [hidden]
    bindl = , XF86AudioMute, exec, wpctl set-mute @DEFAULT_SINK@ toggle # [hidden]
    bindl = $mod+SHIFT, M, exec, wpctl set-mute @DEFAULT_SINK@ toggle # Toggle mute
    bindl = ALT, XF86AudioMute, exec, wpctl set-mute @DEFAULT_SOURCE@ toggle # [hidden]
    bindl = , XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_SOURCE@ toggle # [hidden]
    bindl = $mod+ALT, M, exec, wpctl set-mute @DEFAULT_SOURCE@ toggle # Toggle mic
    # Brightness
    binde = , XF86MonBrightnessUp, exec, brightnessctl s 5%+ # [hidden]
    binde = , XF86MonBrightnessDown, exec, brightnessctl s 5%- # [hidden]

    # Lid switch
    bindl = , switch:on:Lid Switch, exec, hyprctl keyword monitor 'eDP-1,disable' # [hidden]
    bindl = , switch:off:Lid Switch, exec, hyprctl keyword monitor 'eDP-1,preferred,auto,1' # [hidden]

    # Reload
    bindr = CTRL+$mod+ALT, R, exec, hyprctl reload # [hidden]
  '';
in
{
  # Keybinds translated from end-4/dots-hyprland
  # Lines ending with `# [hidden]` won't be shown on cheatsheet
  # Lines starting with ##! are section headings

  # Write keybinds to the path that quickshell expects for cheatsheet parsing
  home.file.".config/hypr/hyprland/keybinds.conf".text = keybindContent;

  # Source the keybinds file in hyprland config
  wayland.windowManager.hyprland.extraConfig = ''
    source = ~/.config/hypr/hyprland/keybinds.conf
  '';

  # Reload Hyprland config after home-manager activation so keybinds take effect
  home.activation.reloadHyprland = lib.hm.dag.entryAfter ["writeBoundary"] ''
    if pgrep Hyprland > /dev/null 2>&1; then
      $DRY_RUN_CMD hyprctl reload 2>/dev/null || true
      echo "Reloaded Hyprland configuration"
    fi
  '';
}
