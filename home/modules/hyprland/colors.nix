# colors.nix - Hyprland colors connected to Stylix base16 scheme
# Automatically adapts to any base16 theme changes
{ config, ... }: 
let
  # Get colors from Stylix base16 scheme
  colors = config.stylix.base16Scheme;
in {
  wayland.windowManager.hyprland.settings = {
    # Base16 color variables (automatically from Stylix)
    "$base00" = "rgb(${colors.base00})"; # base/background
    "$base01" = "rgb(${colors.base01})"; # mantle
    "$base02" = "rgb(${colors.base02})"; # surface0
    "$base03" = "rgb(${colors.base03})"; # surface1
    "$base04" = "rgb(${colors.base04})"; # surface2
    "$base05" = "rgb(${colors.base05})"; # text
    "$base06" = "rgb(${colors.base06})"; # rosewater
    "$base07" = "rgb(${colors.base07})"; # lavender
    "$base08" = "rgb(${colors.base08})"; # red
    "$base09" = "rgb(${colors.base09})"; # peach
    "$base0A" = "rgb(${colors.base0A})"; # yellow
    "$base0B" = "rgb(${colors.base0B})"; # green
    "$base0C" = "rgb(${colors.base0C})"; # teal
    "$base0D" = "rgb(${colors.base0D})"; # blue
    "$base0E" = "rgb(${colors.base0E})"; # mauve
    "$base0F" = "rgb(${colors.base0F})"; # flamingo

    # Semantic color aliases for readability
    "$background" = "$base00";
    "$mantle" = "$base01"; 
    "$surface0" = "$base02";
    "$surface1" = "$base03";
    "$surface2" = "$base04";
    "$text" = "$base05";
    "$rosewater" = "$base06";
    "$lavender" = "$base07";
    "$red" = "$base08";
    "$peach" = "$base09";
    "$yellow" = "$base0A";
    "$green" = "$base0B";
    "$teal" = "$base0C";
    "$blue" = "$base0D";
    "$mauve" = "$base0E";
    "$flamingo" = "$base0F";

    # Window border colors
    general = {
      "col.active_border" = "$mauve $blue 45deg";
      "col.inactive_border" = "$surface0";
    };

    # Group border colors  
    group = {
      "col.border_active" = "$mauve";
      "col.border_inactive" = "$surface0";
      "col.border_locked_active" = "$red";
      "col.border_locked_inactive" = "$surface1";
    };

    # Decoration colors
    decoration = {
      shadow = {
        color = "rgba(${colors.base01}aa)"; # mantle with transparency
        color_inactive = "rgba(${colors.base01}77)";
      };
    };

    # Misc colors
    misc = {
      "col.splash" = "$text";
      background_color = "$background";
    };
  };
}