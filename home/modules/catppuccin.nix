{ config, pkgs, ... }:

{
  # Enable the Catppuccin module
  catppuccin = {
    enable = true;
    flavour = "mocha";  # Options: latte, frappe, macchiato, mocha
    accent = "mauve";   # Options: rosewater, flamingo, pink, mauve, red, maroon, peach, yellow, green, teal, sky, sapphire, blue, lavender
    
    # Enable specific application themes
    programs = {
      kitty.enable = true;
      neovim.enable = true;
      rofi.enable = true;
      vscode.enable = true;
      firefox.enable = true;
      discord.enable = true;
    };
  };
}