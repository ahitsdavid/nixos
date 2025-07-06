{ config, ... }:
{
  programs.fastfetch = {
    enable = true;

    settings = {
      display = {
        color = {
          keys = "#${config.stylix.base16Scheme.base0D}";    # Stylix blue
          output = "#${config.stylix.base16Scheme.base05}";  # Stylix text
        };
        separator = " ➜  ";
      };

      logo = {
        source = ./nixos.png;
        type = "kitty-direct";
        height = 10;
        width = 20;
        padding = {
          top = 2;
          left = 2;
        };
      };

      modules = [
        "break"
        {
          type = "os";
          key = "OS - NixOS";
          keyColor = "#${config.stylix.base16Scheme.base08}";  # Stylix red
        }
        {
          type = "kernel";
          key = " ├  ";
          keyColor = "#${config.stylix.base16Scheme.base08}";  # Stylix red
        }
        {
          type = "packages";
          key = " ├ 󰏖 ";
          keyColor = "#${config.stylix.base16Scheme.base08}";  # Stylix red
        }
        {
          type = "shell";
          key = " └  ";
          keyColor = "#${config.stylix.base16Scheme.base08}";  # Stylix red
        }
        "break"
        {
          type = "wm";
          key = "WM   ";
          keyColor = "#${config.stylix.base16Scheme.base0B}";  # Stylix green
        }
        {
          type = "wmtheme";
          key = " ├ 󰉼 ";
          keyColor = "#${config.stylix.base16Scheme.base0B}";  # Stylix green
        }
        {
          type = "icons";
          key = " ├ 󰀻 ";
          keyColor = "#${config.stylix.base16Scheme.base0B}";  # Stylix green
        }
        {
          type = "cursor";
          key = " ├  ";
          keyColor = "#${config.stylix.base16Scheme.base0B}";  # Stylix green
        }
        {
          type = "terminal";
          key = " ├  ";
          keyColor = "#${config.stylix.base16Scheme.base0B}";  # Stylix green
        }
        {
          type = "terminalfont";
          key = " └  ";
          keyColor = "#${config.stylix.base16Scheme.base0B}";  # Stylix green
        }
        "break"
        {
          type = "host";
          format = "{5} {1} Type {2}";
          key = "PC   ";
          keyColor = "#${config.stylix.base16Scheme.base0A}";  # Stylix yellow
        }
        {
          type = "cpu";
          format = "{1} ({3}) @ {7}";
          key = " ├  ";
          keyColor = "#${config.stylix.base16Scheme.base0A}";  # Stylix yellow
        }
        {
          type = "gpu";
          format = "{1} {2} @ {12}";
          key = " ├ 󰢮 ";
          keyColor = "#${config.stylix.base16Scheme.base0A}";  # Stylix yellow
        }
        {
          type = "memory";
          key = " ├  ";
          keyColor = "#${config.stylix.base16Scheme.base0A}";  # Stylix yellow
        }
        {
          type = "disk";
          key = " ├ 󰋊 ";
          keyColor = "#${config.stylix.base16Scheme.base0A}";  # Stylix yellow
        }
        {
          type = "monitor";
          key = " ├  ";
          keyColor = "#${config.stylix.base16Scheme.base0A}";  # Stylix yellow
        }
        {
          type = "player";
          key = " ├ 󰥠 ";
          keyColor = "#${config.stylix.base16Scheme.base0A}";  # Stylix yellow
        }
        {
          type = "media";
          key = " └ 󰝚 ";
          keyColor = "#${config.stylix.base16Scheme.base0A}";  # Stylix yellow
        }
        "break"
        {
          type = "uptime";
          key = "   Uptime   ";
        }
      ];
    };
  };
}
