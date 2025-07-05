{ config, pkgs, lib, ... }:


{
  # Qt theming configuration (required for Catppuccin kvantum)
  qt = {
    enable = true;
    platformTheme.name = lib.mkForce "kvantum";
    style.name = lib.mkForce "kvantum";  # Required for Catppuccin Qt theming
  };

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
    kvantum.enable = true;
    nvim.enable = false;  # Migrated to Stylix
    obs.enable = true;
    rofi.enable = false;  # Migrated to Stylix
    spotify-player.enable = true;
    vscode.enable = false;  # Migrated to Stylix
    yazi.enable = false;  # Migrated to Stylix
    zed.enable = false;  # Migrated to Stylix
    zed.icons.enable = false;  # Migrated to Stylix
  };
}