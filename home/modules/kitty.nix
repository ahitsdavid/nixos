#home/modules/kitty.nix 
{ pkgs, lib, ... } :
{
  programs.kitty = {
    enable = true;
    # Remove themeFile - let Stylix handle theming
    settings = {
      font_size = 12;
      font = "JetBrainsMono Nerd Font";
      wheel_scroll_min_lines = 1;
      window_padding_width = 4;
      confirm_os_window_close = 0;
      dynamic_background_opacity = true;
      enable_audio_bell = false;
      mouse_hide_wait = "-1.0";
      background_opacity = lib.mkForce "0.7"; # Override Stylix to keep transparency
      background_blur = 5;
      tab_fade = 1;
      active_tab_font_style = "bold";
      inactive_tab_font_style = "bold";
      tab_bar_edge = "top";
      tab_bar_margin_width = 0;
      tab_bar_style = "powerline";
      #tab_bar_style = "fade";
      enabled_layouts = "splits";
      allow_remote_control = true;
      listen_on = "unix:/tmp/kitty";
      # Pass Super key combinations to window manager instead of capturing them
      kitty_mod = "ctrl+shift";
    };
      extraConfig = ''
      # Pass Super key combinations through to Hyprland (don't capture them)
      map super+t no_op
      map super+w no_op
      map super+e no_op
      map super+c no_op
      map super+x no_op
      map super+q no_op
      map super+f no_op
      map super+d no_op
      map super+p no_op
      map super+s no_op
      map super+a no_op
      map super+b no_op
      map super+n no_op
      map super+m no_op
      map super+k no_op
      map super+j no_op
      map super+g no_op
      map super+i no_op
      map super+l no_op
      map super+v no_op
      map super+o no_op
      map super+tab no_op
      map super+space no_op
      map super+return no_op
      map super+slash no_op
      map super+period no_op
      map super+1 no_op
      map super+2 no_op
      map super+3 no_op
      map super+4 no_op
      map super+5 no_op
      map super+6 no_op
      map super+7 no_op
      map super+8 no_op
      map super+9 no_op
      map super+0 no_op
      map super+left no_op
      map super+right no_op
      map super+up no_op
      map super+down no_op

      # Clipboard
      map ctrl+shift+v        paste_from_selection
      map shift+insert        paste_from_selection

      # Scrolling
      map ctrl+shift+up        scroll_line_up
      map ctrl+shift+down      scroll_line_down
      map ctrl+shift+k         scroll_line_up
      map ctrl+shift+j         scroll_line_down
      map ctrl+shift+page_up   scroll_page_up
      map ctrl+shift+page_down scroll_page_down
      map ctrl+shift+home      scroll_home
      map ctrl+shift+end       scroll_end
      map ctrl+shift+h         show_scrollback

      # Window management
      map alt+n               new_window_with_cwd       #open in current dir
      #map alt+n              new_os_window             #opens term in $HOME
      map alt+w               close_window
      map ctrl+shift+enter    launch --location=hsplit
      map ctrl+shift+s        launch --location=vsplit
      map ctrl+shift+]        next_window
      map ctrl+shift+[        previous_window
      map ctrl+shift+f        move_window_forward
      map ctrl+shift+b        move_window_backward
      map ctrl+shift+`        move_window_to_top
      map ctrl+shift+1        first_window
      map ctrl+shift+2        second_window
      map ctrl+shift+3        third_window
      map ctrl+shift+4        fourth_window
      map ctrl+shift+5        fifth_window
      map ctrl+shift+6        sixth_window
      map ctrl+shift+7        seventh_window
      map ctrl+shift+8        eighth_window
      map ctrl+shift+9        ninth_window # Tab management
      map ctrl+shift+0        tenth_window
      map ctrl+shift+right    next_tab
      map ctrl+shift+left     previous_tab
      map ctrl+shift+t        new_tab
      map ctrl+shift+q        close_tab
      map ctrl+shift+l        next_layout
      map ctrl+shift+.        move_tab_forward
      map ctrl+shift+,        move_tab_backward

      # Miscellaneous
      map ctrl+shift+up      increase_font_size
      map ctrl+shift+down    decrease_font_size
      map ctrl+shift+backspace restore_font_size
    '';
  };
}