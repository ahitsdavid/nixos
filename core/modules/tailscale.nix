# core/modules/tailscale.nix
{ pkgs, ... }: {
  # Enable Tailscale service
  services.tailscale = {
    enable = true;
    extraUpFlags = [ "--accept-routes" ];
  };

  # Open firewall for Tailscale
  networking.firewall = {
    # Allow Tailscale UDP port
    allowedUDPPorts = [ 41641 ];
    # Allow traffic from Tailscale network
    trustedInterfaces = [ "tailscale0" ];
  };

  # Add Tailscale package to system
  environment.systemPackages = with pkgs; [
    tailscale
  ];
}
