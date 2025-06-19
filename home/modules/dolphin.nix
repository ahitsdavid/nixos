# modules/dolphin.nix - Home Manager Module
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
    dconf.enable = true;

    home.packages = with pkgs; [
      # Qt6 packages (since Dolphin is Qt6-based)
      qt6Packages.qtstyleplugin-kvantum
      qt6Packages.qt6ct
      # Kvantum manager (Qt5 version but works for configuring both)
      libsForQt5.qtstyleplugin-kvantum
      cfg.package
    ] ++ optionals cfg.plugins [
      kdePackages.dolphin-plugins
    ] ++ optionals cfg.extras [
      kdePackages.kio-extras
    ] ++ optionals cfg.thumbnails [
      kdePackages.kdegraphics-thumbnailers
      kdePackages.ffmpegthumbs
    ] ++ optionals cfg.archiveSupport [
      kdePackages.ark
    ];

    # Configure Qt to use kvantum
    qt = {
      enable = true;
      platformTheme.name = "kvantum";
      style.name = "kvantum";
    };



    home.sessionVariables = mkMerge [
      {
        QT_QPA_PLATFORMTHEME = "kvantum";
        QT_STYLE_OVERRIDE = "kvantum";
        # Force Qt6 to use Kvantum with specific style
        QT6_QPA_PLATFORMTHEME = "kvantum";
        QT6_STYLE_OVERRIDE = "kvantum";
        TERMINAL = cfg.terminal;
      }
      (mkIf cfg.setAsDefault {
        FILE_MANAGER = "dolphin";
      })
    ];

    xdg.mimeApps.defaultApplications = mkIf cfg.setAsDefault {
      "inode/directory" = "org.kde.dolphin.desktop";
    };


  };
}
