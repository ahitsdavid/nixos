# profile/base/networking.nix
{ inputs }:
{ config, pkgs, ... }: {
  networking = {
    extraHosts = ''
      0.0.0.0 apresolve.spotify.com
    '';
    networkmanager = {
      enable = true;
      # Configure DNS to use Tailscale's MagicDNS first, with fallbacks
      dns = "default";
      insertNameservers = [ "100.100.100.100" "8.8.8.8" "1.1.1.1" ];
    };
    firewall = {
      enable = true;
      allowPing = true;

      # Open ports as needed
      allowedTCPPorts = [ 22 8008 8009 53317 ]; # 8008/8009 for Chromecast, 53317 for LocalSend
      allowedUDPPorts = [ 5353 53317 ]; # mDNS for device discovery, 53317 for LocalSend
    };
  };

  # Enable Avahi for mDNS/DNS-SD service discovery (needed for Chromecast)
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };
}