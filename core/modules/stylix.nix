{pkgs, lib, username, ...}: {
# System-wide Stylix Configuration
  stylix = {
    enable = true;
    
    # Catppuccin Mocha theme (direct base16 scheme)
    base16Scheme = {
      base00 = "1e1e2e"; # base
      base01 = "181825"; # mantle
      base02 = "313244"; # surface0
      base03 = "45475a"; # surface1
      base04 = "585b70"; # surface2
      base05 = "cdd6f4"; # text
      base06 = "f5e0dc"; # rosewater
      base07 = "b4befe"; # lavender
      base08 = "f38ba8"; # red
      base09 = "fab387"; # peach
      base0A = "f9e2af"; # yellow
      base0B = "a6e3a1"; # green
      base0C = "94e2d5"; # teal
      base0D = "89b4fa"; # blue
      base0E = "cba6f7"; # mauve
      base0F = "f2cdcd"; # flamingo
      
      scheme = "Catppuccin Mocha";
      author = "https://github.com/catppuccin";
    };
    
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
        package = pkgs.noto-fonts-emoji;
        name = "Noto Color Emoji";
      };
      sizes = {
        applications = 11;
        desktop = 10;
        popups = 10;
        terminal = 12;
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