# home/modules/host-meta.nix
# Exposes current host's metadata to all home-manager modules
{ lib, hostname, ... }:

let
  # Path to the current host's meta.nix
  metaPath = ../../hosts/${hostname}/meta.nix;

  # Import meta.nix if it exists, otherwise use defaults
  hostMeta = if builtins.pathExists metaPath
    then import metaPath
    else {};
in
{
  # Expose host metadata as options so any module can access it
  options.hostMeta = {
    sshAlias = lib.mkOption {
      type = lib.types.str;
      default = hostMeta.sshAlias or "";
      description = "Short SSH alias for this host";
    };

    description = lib.mkOption {
      type = lib.types.str;
      default = hostMeta.description or "";
      description = "Human-readable description of this host";
    };

    hasNvidia = lib.mkOption {
      type = lib.types.bool;
      default = hostMeta.hasNvidia or false;
      description = "Whether this host has an NVIDIA GPU";
    };

    isGaming = lib.mkOption {
      type = lib.types.bool;
      default = hostMeta.isGaming or false;
      description = "Whether this host should have gaming packages";
    };

    isHeadless = lib.mkOption {
      type = lib.types.bool;
      default = hostMeta.isHeadless or false;
      description = "Whether this host is headless (no GUI)";
    };

    isLaptop = lib.mkOption {
      type = lib.types.bool;
      default = hostMeta.isLaptop or false;
      description = "Whether this host is a laptop";
    };

    vncServer = lib.mkOption {
      type = lib.types.bool;
      default = hostMeta.vncServer or false;
      description = "Whether this host runs a VNC server";
    };

    monitors = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = hostMeta.monitors or [ ",preferred,auto,1" ];
      description = "Hyprland monitor configuration";
    };

    syncthingId = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = hostMeta.syncthingId or null;
      description = "Syncthing device ID for this host";
    };

    syncFolders = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = hostMeta.syncFolders or [];
      description = "Folders to sync via Syncthing";
    };
  };
}
