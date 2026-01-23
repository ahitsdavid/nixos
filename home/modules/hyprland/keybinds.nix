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
  # Note: All keybinds are now defined in extraConfig below for cheatsheet compatibility
  # The Nix settings format is not used to avoid duplicate bindings

  # Keybinds with section headers for cheatsheet compatibility
  # This overrides the keybinds defined above
  wayland.windowManager.hyprland.extraConfig = ''
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
    bindid = , Super_L, Toggle overview, global, quickshell:overviewToggleRelease # Toggle overview/launcher

    # Interrupt bindings to prevent launcher on Super release when used in combos
    bind = CTRL, Super_L, global, quickshell:overviewToggleReleaseInterrupt # [hidden]
    bind = $mod, V, global, quickshell:overviewToggleReleaseInterrupt # [hidden]
    bind = $mod, Period, global, quickshell:overviewToggleReleaseInterrupt # [hidden]
    bind = $mod, Tab, global, quickshell:overviewToggleReleaseInterrupt # [hidden]
    bind = $mod, A, global, quickshell:overviewToggleReleaseInterrupt # [hidden]
    bind = $mod, N, global, quickshell:overviewToggleReleaseInterrupt # [hidden]
    bind = $mod, Slash, global, quickshell:overviewToggleReleaseInterrupt # [hidden]
    bind = $mod, K, global, quickshell:overviewToggleReleaseInterrupt # [hidden]
    bind = $mod, M, global, quickshell:overviewToggleReleaseInterrupt # [hidden]
    bind = $mod, C, global, quickshell:overviewToggleReleaseInterrupt # [hidden]
    bind = $mod, Return, global, quickshell:overviewToggleReleaseInterrupt # [hidden]
    bind = $mod, T, global, quickshell:overviewToggleReleaseInterrupt # [hidden]
    bind = $mod, W, global, quickshell:overviewToggleReleaseInterrupt # [hidden]
    bind = $mod+CONTROL, F, global, quickshell:overviewToggleReleaseInterrupt # [hidden]
    bind = $mod, Space, global, quickshell:overviewToggleReleaseInterrupt # [hidden]
    bind = $mod, Left, global, quickshell:overviewToggleReleaseInterrupt # [hidden]
    bind = $mod, Right, global, quickshell:overviewToggleReleaseInterrupt # [hidden]
    bind = $mod, Up, global, quickshell:overviewToggleReleaseInterrupt # [hidden]
    bind = $mod, Down, global, quickshell:overviewToggleReleaseInterrupt # [hidden]
    bind = $mod, bracketleft, global, quickshell:overviewToggleReleaseInterrupt # [hidden]
    bind = $mod, bracketright, global, quickshell:overviewToggleReleaseInterrupt # [hidden]
    bind = $mod, Q, global, quickshell:overviewToggleReleaseInterrupt # [hidden]
    bind = $mod+SHIFT, Left, global, quickshell:overviewToggleReleaseInterrupt # [hidden]
    bind = $mod+SHIFT, Right, global, quickshell:overviewToggleReleaseInterrupt # [hidden]
    bind = $mod+SHIFT, Up, global, quickshell:overviewToggleReleaseInterrupt # [hidden]
    bind = $mod+SHIFT, Down, global, quickshell:overviewToggleReleaseInterrupt # [hidden]
    bind = $mod+SHIFT, Space, global, quickshell:overviewToggleReleaseInterrupt # [hidden]
    bind = $mod, F, global, quickshell:overviewToggleReleaseInterrupt # [hidden]
    bind = $mod, D, global, quickshell:overviewToggleReleaseInterrupt # [hidden]
    bind = $mod, P, global, quickshell:overviewToggleReleaseInterrupt # [hidden]
    bind = $mod, 1, global, quickshell:overviewToggleReleaseInterrupt # [hidden]
    bind = $mod, 2, global, quickshell:overviewToggleReleaseInterrupt # [hidden]
    bind = $mod, 3, global, quickshell:overviewToggleReleaseInterrupt # [hidden]
    bind = $mod, 4, global, quickshell:overviewToggleReleaseInterrupt # [hidden]
    bind = $mod, 5, global, quickshell:overviewToggleReleaseInterrupt # [hidden]
    bind = $mod, 6, global, quickshell:overviewToggleReleaseInterrupt # [hidden]
    bind = $mod, 7, global, quickshell:overviewToggleReleaseInterrupt # [hidden]
    bind = $mod, 8, global, quickshell:overviewToggleReleaseInterrupt # [hidden]
    bind = $mod, 9, global, quickshell:overviewToggleReleaseInterrupt # [hidden]
    bind = $mod, 0, global, quickshell:overviewToggleReleaseInterrupt # [hidden]
    bind = $mod+CONTROL, Right, global, quickshell:overviewToggleReleaseInterrupt # [hidden]
    bind = $mod+CONTROL, Left, global, quickshell:overviewToggleReleaseInterrupt # [hidden]
    bind = $mod, Page_Down, global, quickshell:overviewToggleReleaseInterrupt # [hidden]
    bind = $mod, Page_Up, global, quickshell:overviewToggleReleaseInterrupt # [hidden]
    bind = $mod+CONTROL, Page_Down, global, quickshell:overviewToggleReleaseInterrupt # [hidden]
    bind = $mod+CONTROL, Page_Up, global, quickshell:overviewToggleReleaseInterrupt # [hidden]
    bind = $mod, S, global, quickshell:overviewToggleReleaseInterrupt # [hidden]
    bind = $mod+ALT, 1, global, quickshell:overviewToggleReleaseInterrupt # [hidden]
    bind = $mod+ALT, 2, global, quickshell:overviewToggleReleaseInterrupt # [hidden]
    bind = $mod+ALT, 3, global, quickshell:overviewToggleReleaseInterrupt # [hidden]
    bind = $mod+ALT, 4, global, quickshell:overviewToggleReleaseInterrupt # [hidden]
    bind = $mod+ALT, 5, global, quickshell:overviewToggleReleaseInterrupt # [hidden]
    bind = $mod+ALT, 6, global, quickshell:overviewToggleReleaseInterrupt # [hidden]
    bind = $mod+ALT, 7, global, quickshell:overviewToggleReleaseInterrupt # [hidden]
    bind = $mod+ALT, 8, global, quickshell:overviewToggleReleaseInterrupt # [hidden]
    bind = $mod+ALT, 9, global, quickshell:overviewToggleReleaseInterrupt # [hidden]
    bind = $mod+ALT, 0, global, quickshell:overviewToggleReleaseInterrupt # [hidden]
    bind = $mod+ALT, S, global, quickshell:overviewToggleReleaseInterrupt # [hidden]
    bind = $mod+SHIFT, A, global, quickshell:overviewToggleReleaseInterrupt # [hidden]
    bind = $mod, minus, global, quickshell:overviewToggleReleaseInterrupt # [hidden]
    bind = $mod, equal, global, quickshell:overviewToggleReleaseInterrupt # [hidden]
    bind = $mod, semicolon, global, quickshell:overviewToggleReleaseInterrupt # [hidden]
    bind = $mod, apostrophe, global, quickshell:overviewToggleReleaseInterrupt # [hidden]
    bind = $mod, XF86AudioMute, global, quickshell:overviewToggleReleaseInterrupt # [hidden]
    bind = $mod+CONTROL+ALT, R, global, quickshell:overviewToggleReleaseInterrupt # [hidden]
    bind = $mod, L, global, quickshell:overviewToggleReleaseInterrupt # [hidden]
    bind = $mod+SHIFT, L, global, quickshell:overviewToggleReleaseInterrupt # [hidden]

    ##! Apps
    bind = $mod, C, exec, ~/.config/hypr/scripts/open_vscode_here.sh # VSCode
    bind = $mod, Return, exec, ~/.config/hypr/scripts/launch_first_available.sh '${terminal}' 'kitty -1' 'foot' 'alacritty' 'wezterm' 'konsole' 'kgx' 'uxterm' 'xterm' # Terminal
    bind = $mod, T, exec, ~/.config/hypr/scripts/open_terminal_here.sh # Terminal here
    bind = $mod, W, exec, ~/.config/hypr/scripts/launch_first_available.sh '${browser}' 'zen-browser' 'firefox' 'brave' 'chromium' 'google-chrome-stable' 'microsoft-edge-stable' 'opera' # Browser
    bind = $mod+CONTROL, F, exec, ~/.config/hypr/hyprland/scripts/launch_first_available.sh '${file-manager}' 'dolphin' 'nautilus' 'nemo' 'thunar' # File manager
    bind = $mod, Space, exec, pkill -x rofi || rofi -show drun # Launcher

    ##! Utilities
    bindd = $mod SHIFT, A, OCR text >> Google search, exec, ~/.config/quickshell/scripts/ocr/ocr-search.sh # OCR Search

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
    binde = , XF86MonBrightnessUp, exec, brightnessctl set 5%+ # [hidden]
    binde = , XF86MonBrightnessDown, exec, brightnessctl set 5%- # [hidden]

    bindl = , XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle # [hidden]
    bindl = $mod, XF86AudioMute, exec, wpctl set-mute @DEFAULT_SOURCE@ toggle # [hidden]
    bindl = , switch:on:Lid Switch, exec, hyprctl keyword monitor 'eDP-1,disable' # [hidden]
    bindl = , switch:off:Lid Switch, exec, hyprctl keyword monitor 'eDP-1,preferred,auto,1' # [hidden]

    bindr = $mod CONTROL ALT, R, exec, hyprctl reload # [hidden]
  '';
}