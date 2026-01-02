# core/modules/tailscale.nix
{ config, pkgs, lib, ... }:
let
  # Toggle automatic login on/off
  # NOTE: If you fork this config without the auth key, set this to false
  # Also set hasTailscaleAuthKey = false in sops.nix
  enableAutoLogin = true;  # Set to false to disable auto-login
in
{
  # Enable Tailscale service
  services.tailscale = {
    enable = true;
    # Use auth key from SOPS for automatic login (if enabled)
    authKeyFile = lib.mkIf enableAutoLogin config.sops.secrets."tailscale/auth_key".path;
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
