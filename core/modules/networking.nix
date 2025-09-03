# profile/base/networking.nix
{ inputs }:
{ config, pkgs, ... }: {
  networking = {
    networkmanager.enable = true;
    firewall = {
      enable = true;
      allowPing = true;

      # Open ports as needed
      allowedTCPPorts = [ 22 8008 8009 ]; # 8008/8009 for Chromecast
      allowedUDPPorts = [ 5353 ]; # mDNS for device discovery
    };
  };

  # Enable Avahi for mDNS/DNS-SD service discovery (needed for Chromecast)
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };
}