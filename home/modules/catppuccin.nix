{ config, pkgs, lib, ... }:


{

  # Enable the Catppuccin module
  catppuccin = {
    enable = true;
    flavor = "mocha";  # Options: latte, frappe, macchiato, mocha
    accent = "blue";   # Options: rosewater, flamingo, pink, mauve, red, maroon, peach, yellow, green, teal, sky, sapphire, blue, lavender
    
    # Enable specific application themes
    #gtk.enable = true;
    btop.enable = false;  # Migrated to Stylix
    hyprland.enable = false;
    hyprlock.enable = false;  # Migrated to Stylix
    kitty.enable = false;  # Migrated to Stylix
    kvantum.enable = false;  # Disabled to prevent Quickshell conflicts
    nvim.enable = false;  # Migrated to Stylix
    obs.enable = true;
    rofi.enable = false;  # Migrated to Stylix
    spotify-player.enable = true;
    vscode.profiles.default.enable = false;  # Migrated to Stylix
    yazi.enable = false;  # Miggitrated to Stylix
    zed.enable = false;  # Migrated to Stylix
    zed.icons.enable = false;  # Migrated to Stylix
  };
}