{pkgs, lib, username, ...}: {
# System-wide Stylix Configuration
  stylix = {
    enable = true;
    
    # Catppuccin Mocha theme
    base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";
    
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
        package = pkgs.nerdfonts.override { fonts = [ "FiraCode" ]; };
        name = "FiraCode Nerd Font Mono";
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
      
    };

    # System opacity
    opacity = {
      desktop = 1.0;
      applications = 1.0;
    };
  };
}