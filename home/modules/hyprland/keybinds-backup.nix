{host, ...}: 
let
  inherit
    (import ../../users/davidthach/variables.nix)
    browser
    terminal
    ;
in 
{
  wayland.windowManager.hyprland.settings = {
    # Essential bindings
    bind = [
      "$modifier,Return,exec,${terminal}"
      "$modifier,T,exec,${terminal}"
      "SUPER,SUPER,exec,true"
      
      # Application launchers
      "$modifier,Z,exec,Zed"
      "$modifier,C,exec,code"
      "$modifier,E,exec,nautilus --new-window"
      "$modifier ALT,E,exec,thunar"
      "$modifier,W,exec,${browser} || firefox"
      "$modifier CONTROL,W,exec,firefox"
      "$modifier,X,exec,gnome-text-editor --new-window"
      "$modifier SHIFT,W,exec,wps"
      "$modifier,I,exec,XDG_CURRENT_DESKTOP=\"gnome\" gnome-control-center"
      "$modifier CONTROL,V,exec,pavucontrol"
      "$modifier CONTROL SHIFT,V,exec,easyeffects"
      "CONTROL SHIFT,Escape,exec,gnome-system-monitor"
      "$modifier CONTROL,slash,exec,pkill anyrun || anyrun"
      "$modifier ALT,slash,exec,pkill fuzzel || fuzzel"
      
      # Clipboard and utilities
      "$modifier,V,exec,pkill fuzzel || cliphist list | fuzzel --match-mode fzf --dmenu | cliphist decode | wl-copy"
      "$modifier,period,exec,pkill fuzzel || ~/.local/bin/fuzzel-emoji"
      "CONTROL SHIFT ALT,Delete,exec,pkill wlogout || wlogout -p layer-shell"
      
      # Screenshot and OCR
      "$modifier SHIFT,S,exec,~/.config/ags/scripts/grimblast.sh --freeze copy area"
      "$modifier SHIFT ALT,S,exec,grim -g \"$(slurp)\" - | swappy -f -"
      "$modifier SHIFT,T,exec,grim -g \"$(slurp $SLURP_ARGS)\" \"tmp.png\" && tesseract -l eng \"tmp.png\" - | wl-copy && rm \"tmp.png\""
      "$modifier CONTROL SHIFT,S,exec,grim -g \"$(slurp $SLURP_ARGS)\" \"tmp.png\" && tesseract \"tmp.png\" - | wl-copy && rm \"tmp.png\""
      "$modifier SHIFT,C,exec,hyprpicker -a"
      
      # Session management
      "$modifier CONTROL,L,exec,agsv1 run-js 'lock.lock()'"
      "$modifier,L,exec,loginctl lock-session"
      "$modifier SHIFT,L,exec,loginctl lock-session"
      "CONTROL SHIFT ALT SUPER,Delete,exec,systemctl poweroff || loginctl poweroff"
      
      # Window management
      "$modifier,Left,movefocus,l"
      "$modifier,Right,movefocus,r"
      "$modifier,Up,movefocus,u"
      "$modifier,Down,movefocus,d"
      "$modifier,bracketleft,movefocus,l"
      "$modifier,bracketright,movefocus,r"
      "$modifier,Q,killactive"
      "$modifier SHIFT ALT,Q,exec,hyprctl kill"
      "$modifier SHIFT,Left,movewindow,l"
      "$modifier SHIFT,Right,movewindow,r"
      "$modifier SHIFT,Up,movewindow,u"
      "$modifier SHIFT,Down,movewindow,d"
      "$modifier ALT,Space,togglefloating"
      "$modifier ALT,F,fullscreenstate,0 3"
      "$modifier,F,fullscreen,0"
      "$modifier,D,fullscreen,1"
      "$modifier,P,pin"
      
      # Workspace navigation
      "$modifier,1,exec,~/.config/ags/scripts/hyprland/workspace_action.sh workspace 1"
      "$modifier,2,exec,~/.config/ags/scripts/hyprland/workspace_action.sh workspace 2"
      "$modifier,3,exec,~/.config/ags/scripts/hyprland/workspace_action.sh workspace 3"
      "$modifier,4,exec,~/.config/ags/scripts/hyprland/workspace_action.sh workspace 4"
      "$modifier,5,exec,~/.config/ags/scripts/hyprland/workspace_action.sh workspace 5"
      "$modifier,6,exec,~/.config/ags/scripts/hyprland/workspace_action.sh workspace 6"
      "$modifier,7,exec,~/.config/ags/scripts/hyprland/workspace_action.sh workspace 7"
      "$modifier,8,exec,~/.config/ags/scripts/hyprland/workspace_action.sh workspace 8"
      "$modifier,9,exec,~/.config/ags/scripts/hyprland/workspace_action.sh workspace 9"
      "$modifier,0,exec,~/.config/ags/scripts/hyprland/workspace_action.sh workspace 10"
      "$modifier,mouse_up,workspace,+1"
      "$modifier,mouse_down,workspace,-1"
      "$modifier CONTROL,Right,workspace,r+1" 
      "$modifier CONTROL,Left,workspace,r-1"
      "$modifier,Page_Down,workspace,+1"
      "$modifier,Page_Up,workspace,-1"
      "$modifier CONTROL,Page_Down,workspace,r+1"
      "$modifier CONTROL,Page_Up,workspace,r-1"
      "$modifier,S,togglespecialworkspace"
      "$modifier,mouse:275,togglespecialworkspace"
      "$modifier CONTROL,S,togglespecialworkspace"
      
      # Move to workspace
      "$modifier ALT,1,exec,~/.config/ags/scripts/hyprland/workspace_action.sh movetoworkspacesilent 1"
      "$modifier ALT,2,exec,~/.config/ags/scripts/hyprland/workspace_action.sh movetoworkspacesilent 2"
      "$modifier ALT,3,exec,~/.config/ags/scripts/hyprland/workspace_action.sh movetoworkspacesilent 3"
      "$modifier ALT,4,exec,~/.config/ags/scripts/hyprland/workspace_action.sh movetoworkspacesilent 4"
      "$modifier ALT,5,exec,~/.config/ags/scripts/hyprland/workspace_action.sh movetoworkspacesilent 5"
      "$modifier ALT,6,exec,~/.config/ags/scripts/hyprland/workspace_action.sh movetoworkspacesilent 6"
      "$modifier ALT,7,exec,~/.config/ags/scripts/hyprland/workspace_action.sh movetoworkspacesilent 7"
      "$modifier ALT,8,exec,~/.config/ags/scripts/hyprland/workspace_action.sh movetoworkspacesilent 8"
      "$modifier ALT,9,exec,~/.config/ags/scripts/hyprland/workspace_action.sh movetoworkspacesilent 9"
      "$modifier ALT,0,exec,~/.config/ags/scripts/hyprland/workspace_action.sh movetoworkspacesilent 10"
      "$modifier ALT,S,movetoworkspacesilent,special"
      
      # GUI widgets and components
      "$modifier,Tab,exec,agsv1 -t 'overview'"
      "$modifier,slash,exec,for ((i=0; i<$(hyprctl monitors -j | jq length); i++)); do agsv1 -t \"cheatsheet\"\"$i\"; done"
      "$modifier,B,exec,agsv1 -t 'sideleft'"
      "$modifier,A,exec,agsv1 -t 'sideleft'"
      "$modifier,O,exec,agsv1 -t 'sideleft'"
      "$modifier,N,exec,agsv1 -t 'sideright'"
      "$modifier,M,exec,agsv1 run-js 'openMusicControls.value = (!mpris.getPlayer() ? false : !openMusicControls.value);'"
      "$modifier,comma,exec,agsv1 run-js 'openColorScheme.value = true; Utils.timeout(2000, () => openColorScheme.value = false);'"
      "$modifier,K,exec,for ((i=0; i<$(hyprctl monitors -j | jq length); i++)); do agsv1 -t \"osk\"\"$i\"; done"
      "CONTROL ALT,Delete,exec,for ((i=0; i<$(hyprctl monitors -j | jq length); i++)); do agsv1 -t \"session\"\"$i\"; done"
      
      # Media controls
      "$modifier SHIFT,N,exec,playerctl next || playerctl position `bc <<< \"100 * $(playerctl metadata mpris:length) / 1000000 / 100\"`"
      "$modifier SHIFT,P,exec,playerctl play-pause"
      "$modifier SHIFT,B,exec,playerctl previous"
      "$modifier SHIFT,M,exec,wpctl set-volume @DEFAULT_AUDIO_SINK@ 0%"
      
      # Window cycling
      "ALT,Tab,cyclenext"
      "ALT,Tab,bringactivetotop"
      
      # Function keys and special keys
      ",XF86AudioNext,exec,playerctl next || playerctl position `bc <<< \"100 * $(playerctl metadata mpris:length) / 1000000 / 100\"`"
      ",XF86AudioPrev,exec,playerctl previous"
      ",XF86AudioPlay,exec,playerctl play-pause"
      ",XF86AudioPause,exec,playerctl play-pause"
      ",XF86AudioMute,exec,wpctl set-volume @DEFAULT_AUDIO_SINK@ 0%"
      ",Print,exec,grim - | wl-copy"
      "CONTROL,Print,exec,mkdir -p ~/Pictures/Screenshots && ~/.config/ags/scripts/grimblast.sh copysave screen ~/Pictures/Screenshots/Screenshot_\"$(date '+%Y-%m-%d_%H.%M.%S')\".png"
    ];
    
    # Continuous hold bindings
    binde = [
      "$modifier,minus,splitratio,-0.1"
      "$modifier,equal,splitratio,+0.1"
      "$modifier,semicolon,splitratio,-0.1"
      "$modifier,apostrophe,splitratio,+0.1"
      "$modifier SHIFT,comma,exec,~/.config/ags/scripts/music/adjust-volume.sh -0.03"
      "$modifier SHIFT,period,exec,~/.config/ags/scripts/music/adjust-volume.sh 0.03"
      ",XF86AudioRaiseVolume,exec,wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"
      ",XF86AudioLowerVolume,exec,wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
      ",XF86MonBrightnessUp,exec,agsv1 run-js 'brightness.screen_value += 0.05; indicator.popup(1);'"
      ",XF86MonBrightnessDown,exec,agsv1 run-js 'brightness.screen_value -= 0.05; indicator.popup(1);'"
    ];
    
    # Mouse bindings
    bindm = [
      "$modifier,mouse:272,movewindow"
      "$modifier,mouse:273,resizewindow"
    ];
    
    # Special binding types
    bindl = [
      "$modifier SHIFT,L,exec,sleep 0.1 && systemctl suspend || loginctl suspend"
      "ALT,XF86AudioMute,exec,wpctl set-mute @DEFAULT_SOURCE@ toggle"
      "$modifier,XF86AudioMute,exec,wpctl set-mute @DEFAULT_SOURCE@ toggle"
      "$modifier SHIFT ALT,mouse:275,exec,playerctl previous"
      "$modifier SHIFT ALT,mouse:276,exec,playerctl next || playerctl position `bc <<< \"100 * $(playerctl metadata mpris:length) / 1000000 / 100\"`"
    ];
    
    # Reload related bindings
    bindr = [
      "$modifier CONTROL,R,exec,killall ags agsv1 ydotool; agsv1 &"
      "$modifier CONTROL ALT,R,exec,hyprctl reload; killall agsv1 ydotool; agsv1 &"
    ];
    
    # Special bindings for direct inputs
    bindir = [
      "$modifier,Super_L,exec,agsv1 -t 'overview'"
    ];
  };
}