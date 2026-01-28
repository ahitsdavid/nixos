# home/modules/syncthing.nix
{ config, pkgs, lib, ... }:

{
  services.syncthing = {
    enable = true;
    # Web UI at localhost:8384
    # No tray icon - use keybind to open browser
  };
}
