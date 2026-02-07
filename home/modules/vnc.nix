# home/modules/vnc.nix
{ config, pkgs, lib, ... }:

let
  cfg = config.modules.vnc;
in
{
  options.modules.vnc = {
    server.enable = lib.mkOption {
      type = lib.types.bool;
      default = config.hostMeta.vncServer;
      description = "Enable wayvnc server for remote access to this machine";
    };

    client.enable = lib.mkOption {
      type = lib.types.bool;
      default = !config.hostMeta.vncServer;
      description = "Enable VNC viewer to connect to other machines";
    };
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.server.enable {
      home.packages = with pkgs; [
        wayvnc
      ];
    })

    (lib.mkIf cfg.client.enable {
      home.packages = with pkgs; [
        tigervnc  # vncviewer
      ];
    })
  ];
}
