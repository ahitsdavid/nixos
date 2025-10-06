# home/modules/stylix.nix - Home-manager Stylix configuration
{ config, pkgs, lib, ... }: {
  # Home-manager Stylix configuration
  stylix = {
    # Explicitly enable it
    enable = true;
    
    # Use the same Catppuccin Mocha colors as system (duplicated for reliability)
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
    
    # Home-manager specific targets only
    targets = {
      kitty.enable = true;
      rofi.enable = true;   # Migrated from Catppuccin
      vim.enable = false;
      neovim.enable = false;
      firefox = {
        enable = true;
        profileNames = [ "default" ];
      };
      # Enable GTK theming for better app coverage (e.g., blueman)
      gtk = {
        enable = true;
        # Custom CSS for better context menu styling
        extraCss = ''
          /* Override Adwaita context menu styling */
          popover.menu,
          menu,
          .context-menu {
            background-color: #1e1e2e !important;
            border: 1px solid #45475a !important;
            border-radius: 8px !important;
            padding: 4px !important;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.3) !important;
          }
          
          popover.menu contents,
          menu contents,
          .context-menu contents {
            background-color: #1e1e2e !important;
          }
          
          menuitem,
          popover.menu menuitem,
          .context-menu menuitem {
            background-color: transparent !important;
            color: #cdd6f4 !important;
            padding: 6px 12px !important;
            margin: 2px !important;
            border-radius: 4px !important;
            transition: all 0.2s ease !important;
          }
          
          menuitem:hover,
          popover.menu menuitem:hover,
          .context-menu menuitem:hover {
            background-color: #313244 !important;
            color: #f5e0dc !important;
          }
          
          menuitem:selected,
          popover.menu menuitem:selected,
          .context-menu menuitem:selected {
            background-color: #89b4fa !important;
            color: #1e1e2e !important;
          }
          
          /* Separator styling */
          separator,
          popover.menu separator,
          .context-menu separator {
            background-color: #45475a !important;
            margin: 4px 8px !important;
            min-height: 1px !important;
          }
          
          /* Checkboxes and radio buttons in menus */
          menuitem check,
          menuitem radio,
          popover.menu menuitem check,
          popover.menu menuitem radio {
            background-color: transparent !important;
            color: #89b4fa !important;
          }
          
          menuitem check:checked,
          menuitem radio:checked,
          popover.menu menuitem check:checked,
          popover.menu menuitem radio:checked {
            background-color: #89b4fa !important;
            color: #1e1e2e !important;
          }
          
          /* Submenu arrows */
          menuitem arrow,
          popover.menu menuitem arrow {
            color: #cdd6f4 !important;
          }
          
          /* System tray and status icons context menus */
          .popup-menu,
          .status-icon-menu {
            background-color: #1e1e2e !important;
            border: 1px solid #45475a !important;
            border-radius: 8px !important;
          }
          
          .popup-menu menuitem,
          .status-icon-menu menuitem {
            color: #cdd6f4 !important;
          }
          
          .popup-menu menuitem:hover,
          .status-icon-menu menuitem:hover {
            background-color: #313244 !important;
            color: #f5e0dc !important;
          }
        '';
      };
    };
  };
}