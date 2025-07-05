{ config, pkgs, ... }:


{
  # Enable the Catppuccin module
  catppuccin = {
    enable = true;
    flavor = "mocha";  # Options: latte, frappe, macchiato, mocha
    accent = "blue";   # Options: rosewater, flamingo, pink, mauve, red, maroon, peach, yellow, green, teal, sky, sapphire, blue, lavender
    
    # Enable specific application themes
    #gtk.enable = true;
    hyprland.enable = false;
    hyprlock.enable = true;
    kitty.enable = false;  # Migrated to Stylix
    kvantum.enable = true;
    nvim.enable = true;
    obs.enable = true;
    rofi.enable = true;
    spotify-player.enable = true;
    yazi.enable = true;
    zed.enable = true;
    zed.icons.enable = true;
  };
}