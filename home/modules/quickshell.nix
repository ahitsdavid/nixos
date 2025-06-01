{ config, lib, pkgs, quickshell, ... }:
with lib;
let
  cfg = config.programs.quickshell;
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
    home.packages = [ 
      cfg.package 
      pkgs.material-symbols
      pkgs.libsForQt5.qtgraphicaleffects  # Qt5 GraphicalEffects module
      pkgs.qt6.qt5compat  # Qt6 Qt5 compatibility layer
    ];

    # Alternatively, you can wrap QuickShell with the required Qt modules
    # home.packages = [ 
    #   (pkgs.symlinkJoin {
    #     name = "quickshell-wrapped";
    #     paths = [ cfg.package ];
    #     buildInputs = [ pkgs.makeWrapper ];
    #     postBuild = ''
    #       wrapProgram $out/bin/quickshell \
    #         --prefix QML2_IMPORT_PATH : ${pkgs.libsForQt5.qtgraphicaleffects}/${pkgs.libsForQt5.qtbase.qtQmlPrefix} \
    #         --prefix QML2_IMPORT_PATH : ${pkgs.qt6.qt5compat}/${pkgs.qt6.qtbase.qtQmlPrefix}
    #     '';
    #   })
    # ];

    # Create config symlink if config path is provided
    home.file = mkIf (cfg.config != null) {
      ".config/quickshell".source = cfg.config;
    };

    # Set environment variables for Qt modules
    home.sessionVariables = {
      QML2_IMPORT_PATH = lib.concatStringsSep ":" [
        "${pkgs.libsForQt5.qtgraphicaleffects}/${pkgs.libsForQt5.qtbase.qtQmlPrefix}"
        "${pkgs.qt6.qt5compat}/${pkgs.qt6.qtbase.qtQmlPrefix}"
      ];
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
          "QML2_IMPORT_PATH=${pkgs.libsForQt5.qtgraphicaleffects}/${pkgs.libsForQt5.qtbase.qtQmlPrefix}:${pkgs.qt6.qt5compat}/${pkgs.qt6.qtbase.qtQmlPrefix}"
        ];
      };
      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
    };
  };
}