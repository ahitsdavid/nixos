{ pkgs, lib, username, ... }:
let
  catppuccin = import ../../lib/colors/catppuccin-mocha.nix;
in
{
  # System-wide Stylix Configuration
  stylix = {
    enable = true;

    # Shared Catppuccin Mocha color scheme
    base16Scheme = catppuccin;
    
    # System fonts
    fonts = {
      serif = {
        package = pkgs.noto-fonts;
        name = "Noto Serif";
      };
      sansSerif = {
        package = pkgs.noto-fonts;
        name = "Noto Sans";
      };
      monospace = {
        package = pkgs.nerdfonts.override { fonts = [ "JetBrainsMono" ]; };
        name = "JetBrainsMono Nerd Font Mono";
      };
      emoji = {
        package = pkgs.noto-fonts-color-emoji;
        name = "Noto Color Emoji";
      };
      sizes = {
        applications = 11;
        desktop = 10;
        popups = 10;
        terminal = 14;
      };
    };

    # System-level targets
    targets = {
      # Login manager
      grub = {
        enable = true;
        useImage = true;
      };

      # Boot splash
      plymouth = {
        enable = true;
        logo = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
      };

      # Console
      console.enable = true;

      # GTK system theme
      gtk.enable = true;

      # Applications - gradually replacing Catppuccin
      kitty.enable = true;

      # Disable neovim theming - use Catppuccin instead
      vim.enable = false;
    };

    # System opacity
    opacity = {
      desktop = 1.0;
      applications = 1.0;
    };
  };
}