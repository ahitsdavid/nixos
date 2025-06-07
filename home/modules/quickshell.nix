{ config, lib, pkgs, quickshell, ... }:
with lib;
let
  cfg = config.programs.quickshell;
  qmlImportPath = lib.concatStringsSep ":" [
    "${pkgs.libsForQt5.qtgraphicaleffects}/${pkgs.libsForQt5.qtbase.qtQmlPrefix}"
    "${pkgs.qt6.qt5compat}/${pkgs.qt6.qtbase.qtQmlPrefix}"
    "${pkgs.kdePackages.syntax-highlighting}/lib/qt-6/qml"
  ];
in
{
  options.programs.quickshell = {
    enable = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to enable QuickShell";
    };
    package = mkOption {
      type = types.package;
      default = quickshell.packages.${pkgs.system}.default;
      description = "The QuickShell package to use";
    };
    config = mkOption {
      type = types.nullOr types.path;
      default = null;
      description = "Path to QuickShell configuration directory";
    };
    autostart = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to autostart QuickShell";
    };
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      cfg.package
      gammastep
      gnome-control-center
      gnome-usage
      kdePackages.syntax-highlighting
      material-symbols
      libsForQt5.qtgraphicaleffects # Qt5 GraphicalEffects module
      qt6.qt5compat # Qt6 Qt5 compatibility layer          # Rubik - main font
      rubik    
      nerd-fonts.space-mono    
      better-control
    ];

    # Create config symlink if config path is provided
    home.file = mkIf (cfg.config != null) {
      ".config/quickshell".source = cfg.config;
    };

    # Set environment variables for Qt modules
    home.sessionVariables = {
      QML2_IMPORT_PATH = qmlImportPath;
    };

    # Autostart QuickShell if enabled
    systemd.user.services.quickshell = mkIf cfg.autostart {
      Unit = {
        Description = "QuickShell";
        After = [ "graphical-session-pre.target" ];
        PartOf = [ "graphical-session.target" ];
      };
      Service = {
        ExecStart = "${cfg.package}/bin/quickshell";
        Restart = "on-failure";
        RestartSec = 1;
        TimeoutStopSec = 10;
        Environment = [
          "QML2_IMPORT_PATH=${qmlImportPath}"
        ];
      };
      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
    };
  };
}