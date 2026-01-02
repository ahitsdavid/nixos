# core/modules/tailscale.nix
{ config, pkgs, lib, ... }:
let
  # Toggle automatic login on/off
  enableAutoLogin = true;  # Set to false to disable auto-login

  # Check if SOPS secret exists (fork-friendly: works without SOPS)
  hasAuthKeySecret = enableAutoLogin &&
    (lib.hasAttr "tailscale/auth_key" (config.sops.secrets or {}));
in
{
  # Enable Tailscale service
  services.tailscale = {
    enable = true;
    # Use auth key from SOPS for automatic login (only if secret exists)
    authKeyFile = lib.mkIf hasAuthKeySecret config.sops.secrets."tailscale/auth_key".path;
    extraUpFlags = [ "--accept-routes" ];
    # Use routing features to ensure routes are accepted
    useRoutingFeatures = "both";  # Accept routes and advertise (if needed)
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

  # Configure DNS to use Tailscale's MagicDNS
  networking.nameservers = [ "100.100.100.100" "8.8.8.8" "1.1.1.1" ];

  # Prevent other services from overwriting resolv.conf
  environment.etc."resolv.conf".mode = "direct-symlink";
}
