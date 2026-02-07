# home/modules/foot.nix
# Foot terminal - lightweight Wayland terminal
{ config, pkgs, lib, ... }:

let
  termConfig = import ./terminal-config.nix;
in
{
  programs.foot = {
    enable = true;

    settings = {
      main = {
        shell = termConfig.shell;
        font = "${termConfig.font.family}:size=${toString termConfig.font.size}";
        pad = "${toString termConfig.padding}x${toString termConfig.padding}";
        # Foot uses slightly different opacity format (requires decimal)
      };

      scrollback = {
        lines = termConfig.scrollbackLines;
      };

      bell = {
        urgent = if termConfig.bell then "yes" else "no";
        notify = if termConfig.bell then "yes" else "no";
        visual = if termConfig.bell then "yes" else "no";
      };

      mouse = {
        hide-when-typing = "yes";
      };

      cursor = {
        style = "beam";
        blink = "yes";
      };

      # Catppuccin Mocha colors
      colors = {
        alpha = termConfig.opacity;
        foreground = termConfig.colors.foreground;
        background = termConfig.colors.background;
        selection-foreground = termConfig.colors.selectionForeground;
        selection-background = termConfig.colors.selectionBackground;

        # Normal colors (0-7)
        regular0 = termConfig.colors.black;
        regular1 = termConfig.colors.red;
        regular2 = termConfig.colors.green;
        regular3 = termConfig.colors.yellow;
        regular4 = termConfig.colors.blue;
        regular5 = termConfig.colors.magenta;
        regular6 = termConfig.colors.cyan;
        regular7 = termConfig.colors.white;

        # Bright colors (8-15)
        bright0 = termConfig.colors.brightBlack;
        bright1 = termConfig.colors.brightRed;
        bright2 = termConfig.colors.brightGreen;
        bright3 = termConfig.colors.brightYellow;
        bright4 = termConfig.colors.brightBlue;
        bright5 = termConfig.colors.brightMagenta;
        bright6 = termConfig.colors.brightCyan;
        bright7 = termConfig.colors.brightWhite;
      };

      key-bindings = {
        # Clipboard
        clipboard-copy = "Control+Shift+c";
        clipboard-paste = "Control+Shift+v";
        primary-paste = "Shift+Insert";

        # Scrolling
        scrollback-up-page = "Control+Shift+Page_Up";
        scrollback-down-page = "Control+Shift+Page_Down";
        scrollback-up-line = "Control+Shift+k";
        scrollback-down-line = "Control+Shift+j";
        scrollback-home = "Control+Shift+Home";
        scrollback-end = "Control+Shift+End";

        # Font size
        font-increase = "Control+Shift+plus";
        font-decrease = "Control+Shift+minus";
        font-reset = "Control+Shift+0";

        # Search
        search-start = "Control+Shift+f";

        # Spawn new terminal
        spawn-terminal = "Control+Shift+n";
      };

      search-bindings = {
        find-prev = "Control+Shift+n";
        find-next = "Control+n";
        cursor-left = "Left";
        cursor-right = "Right";
        delete-prev = "BackSpace";
        delete-next = "Delete";
        extend-to-word-boundary = "Control+w";
        extend-to-next-whitespace = "Control+Shift+w";
        cancel = "Escape";
        commit = "Return";
      };
    };
  };
}
