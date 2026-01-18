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
    bindit = , Super_L, submap, super_held # [hidden]
    bindit = , Super_L, global, quickshell:workspaceNumber # [hidden]
    bindid = , Super_L, Toggle overview, global, quickshell:overviewToggleRelease # Toggle overview/launcher
    bindr = , Super_L, submap, reset # [hidden] Exit super_held submap on Super release
    bind = CTRL, Super_L, global, quickshell:overviewToggleReleaseInterrupt # [hidden]

    ##! Apps
    bindu = $mod, C, exec, ~/.config/hypr/scripts/open_vscode_here.sh # VSCode
    bindu = $mod, Return, exec, ~/.config/hypr/scripts/launch_first_available.sh '${terminal}' 'kitty -1' 'foot' 'alacritty' 'wezterm' 'konsole' 'kgx' 'uxterm' 'xterm' # Terminal
    bindu = $mod, T, exec, ~/.config/hypr/scripts/open_terminal_here.sh # Terminal here
    bindu = $mod, W, exec, ~/.config/hypr/scripts/launch_first_available.sh '${browser}' 'zen-browser' 'firefox' 'brave' 'chromium' 'google-chrome-stable' 'microsoft-edge-stable' 'opera' # Browser
    bindu = $mod+CONTROL, F, exec, ~/.config/hypr/hyprland/scripts/launch_first_available.sh '${file-manager}' 'dolphin' 'nautilus' 'nemo' 'thunar' # File manager
    bindu = $mod, Space, exec, pkill -x rofi || rofi -show drun # Launcher

    ##! Window
    bindm = $mod, mouse:272, movewindow # Move
    bindm = $mod, mouse:273, resizewindow # Resize
    bindu = $mod, Left, movefocus, l # [hidden]
    bindu = $mod, Right, movefocus, r # [hidden]
    bindu = $mod, Up, movefocus, u # [hidden]
    bindu = $mod, Down, movefocus, d # [hidden]
    bindu = $mod, bracketleft, movefocus, l # [hidden]
    bindu = $mod, bracketright, movefocus, r # [hidden]
    bindu = $mod, Q, killactive, # Close
    bindu = $mod SHIFT, Left, movewindow, l # [hidden]
    bindu = $mod SHIFT, Right, movewindow, r # [hidden]
    bindu = $mod SHIFT, Up, movewindow, u # [hidden]
    bindu = $mod SHIFT, Down, movewindow, d # [hidden]
    bindu = $mod SHIFT, Space, togglefloating, # Float/Tile
    bindu = $mod, F, fullscreen, 0 # Fullscreen
    bindu = $mod, D, fullscreen, 1 # Maximize
    bindu = $mod, P, pin # Pin

    ##! Workspace
    bindu = $mod, 1, workspace, 1 # [hidden]
    bindu = $mod, 2, workspace, 2 # [hidden]
    bindu = $mod, 3, workspace, 3 # [hidden]
    bindu = $mod, 4, workspace, 4 # [hidden]
    bindu = $mod, 5, workspace, 5 # [hidden]
    bindu = $mod, 6, workspace, 6 # [hidden]
    bindu = $mod, 7, workspace, 7 # [hidden]
    bindu = $mod, 8, workspace, 8 # [hidden]
    bindu = $mod, 9, workspace, 9 # [hidden]
    bindu = $mod, 0, workspace, 10 # [hidden]
    bindu = $mod, mouse_up, workspace, +1 # [hidden]
    bindu = $mod, mouse_down, workspace, -1 # [hidden]
    bindu = $mod CONTROL, Right, workspace, r+1 # [hidden]
    bindu = $mod CONTROL, Left, workspace, r-1 # [hidden]
    bindu = $mod, Page_Down, workspace, +1 # [hidden]
    bindu = $mod, Page_Up, workspace, -1 # [hidden]
    bindu = $mod CONTROL, Page_Down, workspace, r+1 # [hidden]
    bindu = $mod CONTROL, Page_Up, workspace, r-1 # [hidden]
    bindu = $mod, S, togglespecialworkspace, # Toggle scratchpad

    bindu = $mod ALT, 1, movetoworkspacesilent, 1 # [hidden]
    bindu = $mod ALT, 2, movetoworkspacesilent, 2 # [hidden]
    bindu = $mod ALT, 3, movetoworkspacesilent, 3 # [hidden]
    bindu = $mod ALT, 4, movetoworkspacesilent, 4 # [hidden]
    bindu = $mod ALT, 5, movetoworkspacesilent, 5 # [hidden]
    bindu = $mod ALT, 6, movetoworkspacesilent, 6 # [hidden]
    bindu = $mod ALT, 7, movetoworkspacesilent, 7 # [hidden]
    bindu = $mod ALT, 8, movetoworkspacesilent, 8 # [hidden]
    bindu = $mod ALT, 9, movetoworkspacesilent, 9 # [hidden]
    bindu = $mod ALT, 0, movetoworkspacesilent, 10 # [hidden]
    bindu = $mod ALT, S, movetoworkspacesilent, special # [hidden]

    bind = ALT, Tab, cyclenext, # [hidden]
    bind = ALT, Tab, bringactivetotop, # [hidden]

    ##! Session
    bindu = $modifier,L,exec,loginctl lock-session # Lock
    bindu = $modifier SHIFT,L,exec,loginctl lock-session # [hidden]

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

    # Submap for catching all keypresses while Super is held
    # The catchall prevents bindid from firing when combos are used
    submap = super_held
    bind = , escape, submap, reset
    bind = , catchall, submap, reset
    submap = reset
  '';
}