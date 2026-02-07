# home/modules/syncthing.nix
{ config, pkgs, lib, hostname, ... }:

let
  # Import all hosts' metadata
  allHosts = import ./tailscale-hosts.nix;
  hostsDir = ../../hosts;

  # Get full metadata for each host (including syncthingId and syncFolders)
  getHostMeta = name:
    let path = hostsDir + "/${name}/meta.nix";
    in if builtins.pathExists path then import path else {};

  # Build device list from all hosts with syncthingId set
  devices = lib.filterAttrs (name: meta: meta.syncthingId or null != null)
    (lib.mapAttrs (name: _: getHostMeta name) allHosts);

  # Current host's folders to sync
  myFolders = config.hostMeta.syncFolders;

  # For each folder, find other devices that also sync it
  folderDevices = folder:
    lib.filter (name: name != hostname)
      (lib.attrNames (lib.filterAttrs (name: meta:
        builtins.elem folder (meta.syncFolders or [])
      ) (lib.mapAttrs (name: _: getHostMeta name) allHosts)));

in
{
  services.syncthing = {
    enable = true;

    settings = {
      # All known devices
      devices = lib.mapAttrs (name: meta: {
        id = meta.syncthingId;
      }) devices;

      # Folders this host syncs
      folders = lib.listToAttrs (map (folder: {
        name = folder;
        value = {
          path = "~/${folder}";
          devices = folderDevices folder;
        };
      }) myFolders);
    };
  };
}
