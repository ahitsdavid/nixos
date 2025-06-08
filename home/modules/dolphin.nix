# home/modules/dolphin.nix
{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.dolphin;
in
{
  options.programs.dolphin = {
    enable = mkEnableOption "Dolphin file manager";

    package = mkOption {
      type = types.package;
      default = pkgs.kdePackages.dolphin;
      description = "The Dolphin package to use";
    };

    terminal = mkOption {
      type = types.str;
      default = "kitty";
      description = "Default terminal emulator for Dolphin";
    };

    plugins = mkOption {
      type = types.bool;
      default = true;
      description = "Enable Dolphin plugins (version control, etc.)";
    };

    extras = mkOption {
      type = types.bool;
      default = true;
      description = "Enable additional KIO protocols and features";
    };

    thumbnails = mkOption {
      type = types.bool;
      default = true;
      description = "Enable enhanced thumbnail support";
    };

    archiveSupport = mkOption {
      type = types.bool;
      default = true;
      description = "Enable archive integration in context menus";
    };

    setAsDefault = mkOption {
      type = types.bool;
      default = true;
      description = "Set Dolphin as the default file manager";
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      cfg.package
    ] ++ optionals cfg.plugins [
      kdePackages.dolphin-plugins
    ] ++ optionals cfg.extras [
      kdePackages.kio-extras
    ] ++ optionals cfg.thumbnails [
      kdePackages.kdegraphics-thumbnailers
    ] ++ optionals cfg.archiveSupport [
      kdePackages.ark
    ];

    environment.sessionVariables = mkMerge [
      {
        TERMINAL = cfg.terminal;
      }
      (mkIf cfg.setAsDefault {
        FILE_MANAGER = "dolphin";
        TERMINAL = "kitty";
        BROWSER = "firefox";
      })
    ];

    xdg.mime.defaultApplications = mkIf cfg.setAsDefault {
      "inode/directory" = "org.kde.dolphin.desktop";
    };

    # Enable required services
    services.udisks2.enable = mkDefault true;
    services.gvfs.enable = mkDefault true;
    programs.dconf.enable = mkDefault true;
    services.dbus.enable = mkDefault true;
  };
}