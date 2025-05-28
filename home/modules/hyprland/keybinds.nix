{host, username, ...}: 
let
  inherit
    (import ../../users/${username}/variables.nix)
    browser
    terminal
    file-manager
    ;
in 
{
  wayland.windowManager.hyprland.settings = {
    # Define the modifier key
    "$mod" = "SUPER";
    
    # Essential bindings
    bind = [
      # Terminal
      "$mod, Return, exec, ${terminal}"
      "$mod, T, exec, ${terminal}"
      
      # Browser
      "$mod, W, exec, ${browser} || firefox"

      # File Manager
      "$mod CONTROL, F, exec, ${file-manager}"
      
      # Rofi
      "$mod, Space, exec, pkill -x rofi || rofi -show drun"
      
      # Session management
      "$modifier,L,exec,loginctl lock-session"
      "$modifier SHIFT,L,exec,loginctl lock-session"

      # Window management
      "$mod, Left, movefocus, l"
      "$mod, Right, movefocus, r"
      "$mod, Up, movefocus, u"
      "$mod, Down, movefocus, d"
      "$mod, bracketleft, movefocus, l"
      "$mod, bracketright, movefocus, r"
      "$mod, Q, killactive,"
      "$mod SHIFT, Left, movewindow, l"
      "$mod SHIFT, Right, movewindow, r"
      "$mod SHIFT, Up, movewindow, u"
      "$mod SHIFT, Down, movewindow, d"
      "$mod ALT, Space, togglefloating,"
      "$mod, F, fullscreen, 0"
      "$mod, D, fullscreen, 1"
      "$mod, P, pin,"
      
      # Workspace navigation
      "$mod, 1, workspace, 1"
      "$mod, 2, workspace, 2"
      "$mod, 3, workspace, 3"
      "$mod, 4, workspace, 4"
      "$mod, 5, workspace, 5"
      "$mod, 6, workspace, 6"
      "$mod, 7, workspace, 7"
      "$mod, 8, workspace, 8"
      "$mod, 9, workspace, 9"
      "$mod, 0, workspace, 10"
      "$mod, mouse_up, workspace, +1"
      "$mod, mouse_down, workspace, -1"
      "$mod CONTROL, Right, workspace, r+1" 
      "$mod CONTROL, Left, workspace, r-1"
      "$mod, Page_Down, workspace, +1"
      "$mod, Page_Up, workspace, -1"
      "$mod CONTROL, Page_Down, workspace, r+1"
      "$mod CONTROL, Page_Up, workspace, r-1"
      "$mod, S, togglespecialworkspace,"
      
      # Move to workspace
      "$mod ALT, 1, movetoworkspacesilent, 1"
      "$mod ALT, 2, movetoworkspacesilent, 2"
      "$mod ALT, 3, movetoworkspacesilent, 3"
      "$mod ALT, 4, movetoworkspacesilent, 4"
      "$mod ALT, 5, movetoworkspacesilent, 5"
      "$mod ALT, 6, movetoworkspacesilent, 6"
      "$mod ALT, 7, movetoworkspacesilent, 7"
      "$mod ALT, 8, movetoworkspacesilent, 8"
      "$mod ALT, 9, movetoworkspacesilent, 9"
      "$mod ALT, 0, movetoworkspacesilent, 10"
      "$mod ALT, S, movetoworkspacesilent, special"
      
      # Window cycling
      "ALT, Tab, cyclenext,"
      "ALT, Tab, bringactivetotop,"
      
      # Basic media controls
      ", XF86AudioPlay, exec, playerctl play-pause"
      ", XF86AudioNext, exec, playerctl next"
      ", XF86AudioPrev, exec, playerctl previous"
    ];
    
    # Continuous hold bindings
    binde = [
      "$mod, minus, splitratio, -0.1"
      "$mod, equal, splitratio, +0.1"
      "$mod, semicolon, splitratio, -0.1"
      "$mod, apostrophe, splitratio, +0.1"
      ", XF86AudioRaiseVolume, exec, wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"
      ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
    ];
    
    # Mouse bindings
    bindm = [
      "$mod, mouse:272, movewindow"
      "$mod, mouse:273, resizewindow"
    ];
    
    # Special binding types
    bindl = [
      ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
      "$mod, XF86AudioMute, exec, wpctl set-mute @DEFAULT_SOURCE@ toggle"
    ];
    
    # Reload Hyprland
    bindr = [
      "$mod CONTROL ALT, R, exec, hyprctl reload"
    ];
  };
}
