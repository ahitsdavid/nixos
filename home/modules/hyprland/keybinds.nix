{ host, username, ... }:
let
  inherit
    (import ../../users/${username}/variables.nix)
    browser
    terminal
    file-manager
    ;
in
{
  # Keybinds with section headers for cheatsheet compatibility
  # Lines ending with `# [hidden]` won't be shown on cheatsheet
  # Lines starting with ##! are section headings
  wayland.windowManager.hyprland.extraConfig = ''
    # Define modifier variables
    $mod = Super

    #!
    ##! Shell
    # Super key release triggers search/launcher - these must be at the top
    bindid = $mod, Super_L, Toggle search, global, quickshell:searchToggleRelease # Toggle search
    bindid = $mod, Super_R, Toggle search, global, quickshell:searchToggleRelease # [hidden]
    # Fallback launcher when quickshell isn't running
    bind = $mod, Super_L, exec, qs ipc call TEST_ALIVE || pkill fuzzel || fuzzel # [hidden]
    bind = $mod, Super_R, exec, qs ipc call TEST_ALIVE || pkill fuzzel || fuzzel # [hidden]
    # Catchall to interrupt launcher on any Super+key combo (Hyprland 0.53.1+)
    # Note: catchall only works in submaps, disabled for now
    # binditn = $mod, catchall, global, quickshell:searchToggleReleaseInterrupt # [hidden]
    bind = Ctrl, Super_L, global, quickshell:searchToggleReleaseInterrupt # [hidden]
    bind = Ctrl, Super_R, global, quickshell:searchToggleReleaseInterrupt # [hidden]
    # Mouse interrupts
    bind = $mod, mouse:272, global, quickshell:searchToggleReleaseInterrupt # [hidden]
    bind = $mod, mouse:273, global, quickshell:searchToggleReleaseInterrupt # [hidden]
    bind = $mod, mouse:274, global, quickshell:searchToggleReleaseInterrupt # [hidden]
    bind = $mod, mouse:275, global, quickshell:searchToggleReleaseInterrupt # [hidden]
    bind = $mod, mouse:276, global, quickshell:searchToggleReleaseInterrupt # [hidden]
    bind = $mod, mouse:277, global, quickshell:searchToggleReleaseInterrupt # [hidden]
    bind = $mod, mouse_up, global, quickshell:searchToggleReleaseInterrupt # [hidden]
    bind = $mod, mouse_down, global, quickshell:searchToggleReleaseInterrupt # [hidden]

    # Workspace number display on Super hold
    bindit = , Super_L, global, quickshell:workspaceNumber # [hidden]
    bindit = , Super_R, global, quickshell:workspaceNumber # [hidden]

    # Overview and sidebars
    bind = $mod, Tab, global, quickshell:overviewWorkspacesToggle # Toggle overview
    bindd = $mod, V, Clipboard history >> clipboard, global, quickshell:overviewClipboardToggle # Clipboard history >> clipboard
    bindd = $mod, Period, Emoji >> clipboard, global, quickshell:overviewEmojiToggle # Emoji >> clipboard
    bind = $mod, A, global, quickshell:sidebarLeftToggle # Toggle left sidebar
    bind = $mod+Alt, A, global, quickshell:sidebarLeftToggleDetach # [hidden]
    bind = $mod, B, global, quickshell:sidebarLeftToggle # [hidden]
    bind = $mod, O, global, quickshell:sidebarLeftToggle # [hidden]
    bindd = $mod, N, Toggle right sidebar, global, quickshell:sidebarRightToggle # Toggle right sidebar
    bindd = $mod, Slash, Toggle cheatsheet, global, quickshell:cheatsheetToggle # Toggle cheatsheet
    bindd = $mod, K, Toggle on-screen keyboard, global, quickshell:oskToggle # Toggle on-screen keyboard
    bindd = $mod, M, Toggle media controls, global, quickshell:mediaControlsToggle # Toggle media controls
    bind = $mod, G, global, quickshell:overlayToggle # Toggle overlay
    bindd = Ctrl+Alt, Delete, Toggle session menu, global, quickshell:sessionToggle # Toggle session menu
    bindd = $mod, J, Toggle bar, global, quickshell:barToggle # Toggle bar
    # Session menu fallback
    bind = Ctrl+Alt, Delete, exec, qs ipc call TEST_ALIVE || pkill wlogout || wlogout -p layer-shell # [hidden]

    # Clipboard/emoji fallbacks
    bindd = $mod, V, Copy clipboard history entry, exec, qs ipc call TEST_ALIVE || pkill fuzzel || cliphist list | fuzzel --match-mode fzf --dmenu | cliphist decode | wl-copy # [hidden]

    # Brightness (with quickshell integration)
    bindle = , XF86MonBrightnessUp, exec, qs ipc call brightness increment || brightnessctl s 5%+ # [hidden]
    bindle = , XF86MonBrightnessDown, exec, qs ipc call brightness decrement || brightnessctl s 5%- # [hidden]
    # Volume
    bindle = , XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 2%+ -l 1.5 # [hidden]
    bindle = , XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 2%- # [hidden]
    bindl = , XF86AudioMute, exec, wpctl set-mute @DEFAULT_SINK@ toggle # [hidden]
    bindld = $mod+Shift, M, Toggle mute, exec, wpctl set-mute @DEFAULT_SINK@ toggle # Toggle mute
    bindl = Alt, XF86AudioMute, exec, wpctl set-mute @DEFAULT_SOURCE@ toggle # [hidden]
    bindl = , XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_SOURCE@ toggle # [hidden]
    bindld = $mod+Alt, M, Toggle mic, exec, wpctl set-mute @DEFAULT_SOURCE@ toggle # Toggle mic

    # Wallpaper selector
    bindd = Ctrl+$mod, T, Toggle wallpaper selector, global, quickshell:wallpaperSelectorToggle # Wallpaper selector
    bindd = Ctrl+$mod+Alt, T, Select random wallpaper, global, quickshell:wallpaperSelectorRandom # Random wallpaper
    # Wallpaper fallback
    bindd = Ctrl+$mod, T, Change wallpaper, exec, qs ipc call TEST_ALIVE || ~/.config/quickshell/scripts/colors/switchwall.sh # [hidden]

    # Widget controls
    bind = Ctrl+$mod, R, exec, killall ags agsv1 gjs ydotool qs quickshell; qs & # Restart widgets
    bind = Ctrl+$mod, P, global, quickshell:panelFamilyCycle # Cycle panel family

    ##! Utilities
    # Screenshot
    bind = $mod+Shift, S, global, quickshell:regionScreenshot # Screen snip
    bind = $mod+Shift, S, exec, qs ipc call TEST_ALIVE || pidof slurp || hyprshot --freeze --clipboard-only --mode region --silent # [hidden]
    # Google Lens / OCR search
    bind = $mod+Shift, A, global, quickshell:regionSearch # Google Lens
    bind = $mod+Shift, A, exec, qs ipc call TEST_ALIVE || ~/.config/quickshell/scripts/ocr/ocr-search.sh # [hidden]
    # OCR to clipboard
    bind = $mod+Shift, X, global, quickshell:regionOcr # Character recognition >> clipboard
    # Color picker
    bindd = $mod+Shift, C, Color picker, exec, hyprpicker -a # Pick color (Hex) >> clipboard
    # Fullscreen screenshot
    bindl = , Print, exec, grim - | wl-copy # Screenshot >> clipboard
    bindln = Ctrl, Print, exec, mkdir -p $(xdg-user-dir PICTURES)/Screenshots && grim $(xdg-user-dir PICTURES)/Screenshots/Screenshot_"$(date '+%Y-%m-%d_%H.%M.%S')".png # Screenshot >> file
    bindln = Ctrl, Print, exec, grim - | wl-copy # [hidden]
    # Recording
    bindl = $mod+Shift, R, global, quickshell:regionRecord # Record region (no sound)
    bindl = $mod+Shift, R, exec, qs ipc call TEST_ALIVE || ~/.config/quickshell/scripts/videos/record.sh # [hidden]
    bindl = $mod+Alt, R, global, quickshell:regionRecord # [hidden]
    bindl = Ctrl+Alt, R, exec, ~/.config/quickshell/scripts/videos/record.sh --fullscreen # Record screen (no sound)
    bindl = $mod+Shift+Alt, R, exec, ~/.config/quickshell/scripts/videos/record.sh --fullscreen --sound # Record screen (with sound)

    #!
    ##! Window
    # Mouse bindings
    bindm = $mod, mouse:272, movewindow # Move
    bindm = $mod, mouse:274, movewindow # [hidden]
    bindm = $mod, mouse:273, resizewindow # Resize
    # Focus direction
    bind = $mod, Left, movefocus, l # [hidden]
    bind = $mod, Right, movefocus, r # [hidden]
    bind = $mod, Up, movefocus, u # [hidden]
    bind = $mod, Down, movefocus, d # [hidden]
    bind = $mod, BracketLeft, movefocus, l # [hidden]
    bind = $mod, BracketRight, movefocus, r # [hidden]
    # Move window in direction
    bind = $mod+Shift, Left, movewindow, l # [hidden]
    bind = $mod+Shift, Right, movewindow, r # [hidden]
    bind = $mod+Shift, Up, movewindow, u # [hidden]
    bind = $mod+Shift, Down, movewindow, d # [hidden]
    # Close window
    bind = Alt, F4, killactive, # [hidden]
    bind = $mod, Q, killactive, # Close
    bind = $mod+Shift+Alt, Q, exec, hyprctl kill # Forcefully zap a window
    # Split ratio
    binde = $mod, Semicolon, splitratio, -0.1 # [hidden]
    binde = $mod, Apostrophe, splitratio, +0.1 # [hidden]
    # Positioning mode
    bind = $mod+Alt, Space, togglefloating, # Float/Tile
    bind = $mod, D, fullscreen, 1 # Maximize
    bind = $mod, F, fullscreen, 0 # Fullscreen
    bind = $mod+Alt, F, fullscreenstate, 0 3 # Fullscreen spoof
    bind = $mod, P, pin # Pin

    # Send to workspace (using raw keycodes for keyboard layout compatibility)
    bind = $mod+Alt, code:10, movetoworkspacesilent, 1 # [hidden]
    bind = $mod+Alt, code:11, movetoworkspacesilent, 2 # [hidden]
    bind = $mod+Alt, code:12, movetoworkspacesilent, 3 # [hidden]
    bind = $mod+Alt, code:13, movetoworkspacesilent, 4 # [hidden]
    bind = $mod+Alt, code:14, movetoworkspacesilent, 5 # [hidden]
    bind = $mod+Alt, code:15, movetoworkspacesilent, 6 # [hidden]
    bind = $mod+Alt, code:16, movetoworkspacesilent, 7 # [hidden]
    bind = $mod+Alt, code:17, movetoworkspacesilent, 8 # [hidden]
    bind = $mod+Alt, code:18, movetoworkspacesilent, 9 # [hidden]
    bind = $mod+Alt, code:19, movetoworkspacesilent, 10 # [hidden]
    # Send with scroll/page
    bind = $mod+Shift, mouse_down, movetoworkspace, r-1 # [hidden]
    bind = $mod+Shift, mouse_up, movetoworkspace, r+1 # [hidden]
    bind = $mod+Alt, mouse_down, movetoworkspace, -1 # [hidden]
    bind = $mod+Alt, mouse_up, movetoworkspace, +1 # [hidden]
    bind = $mod+Alt, Page_Down, movetoworkspace, +1 # [hidden]
    bind = $mod+Alt, Page_Up, movetoworkspace, -1 # [hidden]
    bind = $mod+Shift, Page_Down, movetoworkspace, r+1 # [hidden]
    bind = $mod+Shift, Page_Up, movetoworkspace, r-1 # [hidden]
    bind = Ctrl+$mod+Shift, Right, movetoworkspace, r+1 # [hidden]
    bind = Ctrl+$mod+Shift, Left, movetoworkspace, r-1 # [hidden]
    bind = $mod+Alt, S, movetoworkspacesilent, special # Send to scratchpad

    ##! Workspace
    # Switch workspace (using raw keycodes for keyboard layout compatibility)
    bind = $mod, code:10, workspace, 1 # [hidden]
    bind = $mod, code:11, workspace, 2 # [hidden]
    bind = $mod, code:12, workspace, 3 # [hidden]
    bind = $mod, code:13, workspace, 4 # [hidden]
    bind = $mod, code:14, workspace, 5 # [hidden]
    bind = $mod, code:15, workspace, 6 # [hidden]
    bind = $mod, code:16, workspace, 7 # [hidden]
    bind = $mod, code:17, workspace, 8 # [hidden]
    bind = $mod, code:18, workspace, 9 # [hidden]
    bind = $mod, code:19, workspace, 10 # [hidden]
    # Navigate workspaces
    bind = Ctrl+$mod, Right, workspace, r+1 # [hidden]
    bind = Ctrl+$mod, Left, workspace, r-1 # [hidden]
    bind = Ctrl+$mod+Alt, Right, workspace, m+1 # [hidden]
    bind = Ctrl+$mod+Alt, Left, workspace, m-1 # [hidden]
    bind = $mod, Page_Down, workspace, +1 # [hidden]
    bind = $mod, Page_Up, workspace, -1 # [hidden]
    bind = Ctrl+$mod, Page_Down, workspace, r+1 # [hidden]
    bind = Ctrl+$mod, Page_Up, workspace, r-1 # [hidden]
    bind = $mod, mouse_up, workspace, +1 # [hidden]
    bind = $mod, mouse_down, workspace, -1 # [hidden]
    bind = Ctrl+$mod, mouse_up, workspace, r+1 # [hidden]
    bind = Ctrl+$mod, mouse_down, workspace, r-1 # [hidden]
    # Special workspace
    bind = $mod, S, togglespecialworkspace, # Toggle scratchpad
    bind = $mod, mouse:275, togglespecialworkspace, # [hidden]
    bind = Ctrl+$mod, S, togglespecialworkspace, # [hidden]
    bind = Ctrl+$mod, BracketLeft, workspace, -1 # [hidden]
    bind = Ctrl+$mod, BracketRight, workspace, +1 # [hidden]
    bind = Ctrl+$mod, Up, workspace, r-5 # [hidden]
    bind = Ctrl+$mod, Down, workspace, r+5 # [hidden]
    # Alt+Tab cycling
    bind = Alt, Tab, cyclenext, # [hidden]
    bind = Alt, Tab, bringactivetotop, # [hidden]

    ##! Virtual machines
    bind = $mod+Alt, F1, exec, notify-send 'Entered Virtual Machine submap' 'Keybinds disabled. Hit Super+Alt+F1 to escape' -a 'Hyprland' && hyprctl dispatch submap virtual-machine # Disable keybinds
    submap = virtual-machine
    bind = $mod+Alt, F1, exec, notify-send 'Exited Virtual Machine submap' 'Keybinds re-enabled' -a 'Hyprland' && hyprctl dispatch submap global # [hidden]
    submap = global

    ##! Session
    bindd = $mod, L, Lock, exec, loginctl lock-session # Lock
    bindld = $mod+Shift, L, Suspend system, exec, systemctl suspend || loginctl suspend # Sleep
    bindd = Ctrl+Shift+Alt+$mod, Delete, Shutdown, exec, systemctl poweroff || loginctl poweroff # [hidden]

    ##! Screen
    # Zoom
    binde = $mod, Minus, exec, ~/.config/hypr/scripts/zoom.sh decrease 0.3 # [hidden]
    binde = $mod, Equal, exec, ~/.config/hypr/scripts/zoom.sh increase 0.3 # [hidden]
    # Zoom with keypad
    binde = $mod, code:82, exec, qs ipc call zoom zoomOut # [hidden]
    binde = $mod, code:86, exec, qs ipc call zoom zoomIn # [hidden]

    ##! Media
    bindl = $mod+Shift, N, exec, playerctl next || playerctl position $(bc <<< "100 * $(playerctl metadata mpris:length) / 1000000 / 100") # Next track
    bindl = , XF86AudioNext, exec, playerctl next || playerctl position $(bc <<< "100 * $(playerctl metadata mpris:length) / 1000000 / 100") # [hidden]
    bindl = , XF86AudioPrev, exec, playerctl previous # [hidden]
    bind = $mod+Shift+Alt, mouse:275, exec, playerctl previous # [hidden]
    bind = $mod+Shift+Alt, mouse:276, exec, playerctl next # [hidden]
    bindl = $mod+Shift, B, exec, playerctl previous # Previous track
    bindl = $mod+Shift, P, exec, playerctl play-pause # Play/pause media
    bindl = , XF86AudioPlay, exec, playerctl play-pause # [hidden]
    bindl = , XF86AudioPause, exec, playerctl play-pause # [hidden]

    ##! Apps
    bind = $mod, Return, exec, ~/.config/hypr/scripts/launch_first_available.sh '${terminal}' 'kitty -1' 'foot' 'alacritty' 'wezterm' 'konsole' 'kgx' 'uxterm' 'xterm' # Terminal
    bind = $mod, T, exec, ~/.config/hypr/scripts/launch_first_available.sh '${terminal}' 'kitty -1' 'foot' 'alacritty' 'wezterm' 'konsole' 'kgx' 'uxterm' 'xterm' # [hidden]
    bind = Ctrl+Alt, T, exec, ~/.config/hypr/scripts/launch_first_available.sh '${terminal}' 'kitty -1' 'foot' 'alacritty' 'wezterm' 'konsole' 'kgx' 'uxterm' 'xterm' # [hidden]
    bind = $mod, E, exec, ~/.config/hypr/scripts/launch_first_available.sh 'dolphin' 'nautilus' 'nemo' 'thunar' '${file-manager}' # File manager
    bind = $mod, W, exec, ~/.config/hypr/scripts/launch_first_available.sh '${browser}' 'zen-browser' 'google-chrome-stable' 'firefox' 'brave' 'chromium' 'microsoft-edge-stable' 'opera' 'librewolf' # Browser
    bind = $mod, C, exec, ~/.config/hypr/scripts/launch_first_available.sh 'code' 'codium' 'cursor' 'zed' 'kate' 'gnome-text-editor' 'emacs' # Code editor
    bind = $mod, X, exec, ~/.config/hypr/scripts/launch_first_available.sh 'kate' 'gnome-text-editor' 'emacs' # Text editor
    bind = Ctrl+$mod, V, exec, ~/.config/hypr/scripts/launch_first_available.sh 'pavucontrol-qt' 'pavucontrol' # Volume mixer
    bind = $mod, I, exec, XDG_CURRENT_DESKTOP=gnome ~/.config/hypr/scripts/launch_first_available.sh 'systemsettings' 'gnome-control-center' 'better-control' # Settings app
    bind = Ctrl+Shift, Escape, exec, ~/.config/hypr/scripts/launch_first_available.sh 'gnome-system-monitor' 'plasma-systemmonitor' # Task manager

    # Lid switch
    bindl = , switch:on:Lid Switch, exec, hyprctl keyword monitor 'eDP-1,disable' # [hidden]
    bindl = , switch:off:Lid Switch, exec, hyprctl keyword monitor 'eDP-1,preferred,auto,1' # [hidden]

    # Resize window to specific size
    bind = Ctrl+$mod, Backslash, resizeactive, exact 640 480 # [hidden]

    # Reload config
    bind = Ctrl+$mod+Alt, R, exec, hyprctl reload # [hidden]
  '';
}