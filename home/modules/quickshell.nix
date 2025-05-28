{ config, lib, pkgs, inputs, ... }:

with lib;

let
  cfg = config.programs.quickshell;
in
{
  options.programs.quickshell = {
    enable = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to enable quickshell";
    };

    configFile = mkOption {
      type = types.path;
      default = ./config/quickshell.qml;
      description = "Path to quickshell configuration file";
    };

    package = mkOption {
      type = types.package;
      default = inputs.quickshell.packages.${pkgs.system}.default;
      description = "The quickshell package to use";
    };

    extraArgs = mkOption {
      type = types.listOf types.str;
      default = [];
      description = "Extra arguments to pass to quickshell";
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ cfg.package ];

    xdg.configFile."quickshell/config.qml".source = cfg.configFile;

    systemd.user.services.quickshell = {
      Unit = {
        Description = "Quickshell";
        After = [ "graphical-session-pre.target" ];
        PartOf = [ "graphical-session.target" ];
      };

      Service = {
        ExecStart = "${cfg.package}/bin/quickshell ${concatStringsSep " " cfg.extraArgs}";
        Restart = "on-failure";
        RestartSec = 1;
        TimeoutStopSec = 10;
      };

      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
    };
  };
}