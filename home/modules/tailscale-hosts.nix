# home/modules/tailscale-hosts.nix
# Dynamically aggregates host metadata from hosts/*/meta.nix
# Each host defines its own sshAlias and description

let
  hostsDir = ../../hosts;

  # Read all entries in hosts directory
  hostEntries = builtins.readDir hostsDir;

  # Filter to only directories that have a meta.nix file
  hostNames = builtins.filter (name:
    hostEntries.${name} == "directory" &&
    builtins.pathExists (hostsDir + "/${name}/meta.nix")
  ) (builtins.attrNames hostEntries);

  # Import each host's meta.nix and build the hosts attrset
  # { desktop = { alias = "sd"; description = "..."; }; ... }
  hosts = builtins.listToAttrs (builtins.map (name: {
    inherit name;
    value = let
      meta = import (hostsDir + "/${name}/meta.nix");
    in {
      alias = meta.sshAlias;
      description = meta.description or "";
    };
  }) hostNames);

in hosts
