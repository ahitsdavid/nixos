# core/modules/tailscale.nix
{ config, pkgs, lib, ... }:
let
  cfg = config.services.tailscale;

  # Check if SOPS secret exists (fork-friendly: works without SOPS)
  hasAuthKeySecret = cfg.autoLogin &&
    (lib.hasAttr "tailscale/auth_key" (config.sops.secrets or {}));
in
{
  options.services.tailscale.autoLogin = lib.mkOption {
    type = lib.types.bool;
    default = false;
    description = "Whether to automatically login to Tailscale using SOPS auth key";
  };

  config = {
    # Enable Tailscale service
    services.tailscale = {
      enable = true;
      # Use auth key from SOPS for automatic login (only if secret exists and autoLogin is enabled)
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
  };
}
