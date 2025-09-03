# profile/base/networking.nix
{ inputs }:
{ config, pkgs, ... }: {
  networking = {
    networkmanager.enable = true;
    firewall = {
      enable = true;
      allowPing = true;

      # Open ports as needed
      allowedTCPPorts = [ 22 ];
    };
  };
}