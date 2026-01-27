#home/modules/kitty.nix
{ pkgs, lib, ... } :
let
  kitty_grab = pkgs.fetchFromGitHub {
    owner = "yurikhan";
    repo = "kitty_grab";
    rev = "969e363295b48f62fdcbf29987c77ac222109c41";
    hash = "sha256-DamZpYkyVjxRKNtW5LTLX1OU47xgd/ayiimDorVSamE=";
  };
in
{
  # Kitty grab kitten for vim-style text selection
  home.file.".config/kitty/kitty_grab".source = kitty_grab;

  # Vim-style grab config
  home.file.".config/kitty/grab.conf".text = ''
    # Vim-style kitty_grab config

    # Colors
    selection_foreground #1e1e2e
    selection_background #89b4fa

    # Quit/confirm
    map q quit
    map Escape quit
    map y confirm

    # Movement (vim-style)
    map h move left
    map j move down
    map k move up
    map l move right
    map w move word
    map b move word_end left
    map e move word_end
    map 0 move first
    map $ move last
    map g move top
    map G move bottom
    map ctrl+u move page up
    map ctrl+d move page down

    # Visual mode (stream selection)
    map v set_mode visual
    map V select stream left first

    # Block selection
    map ctrl+v set_mode block

    # Scrolling
    map ctrl+y scroll up
    map ctrl+e scroll down
  '';

  programs.kitty = {
    enable = true;
    # Remove themeFile - let Stylix handle theming
    settings = {
      shell = "zsh";
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
    };
      extraConfig = ''

      # Kitty grab - vim-style visual selection
      map alt+g kitten kitty_grab/grab.py

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