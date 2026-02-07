# home/modules/terminal-config.nix
# Shared terminal settings for Kitty and Foot
{
  # Font settings
  font = {
    family = "JetBrainsMono Nerd Font";
    size = 12;
  };

  # Appearance
  padding = 4;
  opacity = 0.7;

  # Behavior
  shell = "fish";  # Use Fish as default terminal shell
  bell = false;    # Disable audio bell

  # Scrollback
  scrollbackLines = 10000;

  # Catppuccin Mocha colors (for terminals that need manual theming)
  colors = {
    foreground = "cdd6f4";
    background = "1e1e2e";
    selectionForeground = "1e1e2e";
    selectionBackground = "89b4fa";

    # Normal colors
    black = "45475a";
    red = "f38ba8";
    green = "a6e3a1";
    yellow = "f9e2af";
    blue = "89b4fa";
    magenta = "cba6f7";
    cyan = "94e2d5";
    white = "bac2de";

    # Bright colors
    brightBlack = "585b70";
    brightRed = "f38ba8";
    brightGreen = "a6e3a1";
    brightYellow = "f9e2af";
    brightBlue = "89b4fa";
    brightMagenta = "cba6f7";
    brightCyan = "94e2d5";
    brightWhite = "a6adc8";
  };
}
