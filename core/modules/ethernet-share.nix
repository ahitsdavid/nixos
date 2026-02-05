# Ethernet connection sharing between two machines
# One acts as gateway (NAT), the other as client
{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.networking.ethernet-share;
  subnet = "10.10.10";
in
{
  options.networking.ethernet-share = {
    gateway = {
      enable = mkEnableOption "ethernet sharing gateway (NAT to this machine's internet)";

      interface = mkOption {
        type = types.str;
        description = "Ethernet interface for the direct link to client";
        example = "enp66s0";
      };

      ip = mkOption {
        type = types.str;
        default = "${subnet}.1";
        description = "IP address on the tunnel interface";
      };
    };

    client = {
      enable = mkEnableOption "ethernet sharing client (route through gateway)";

      interface = mkOption {
        type = types.str;
        description = "Ethernet interface for the direct link to gateway";
        example = "enp0s31f6";
      };

      ip = mkOption {
        type = types.str;
        default = "${subnet}.2";
        description = "IP address on the tunnel interface";
      };

      gatewayIP = mkOption {
        type = types.str;
        default = "${subnet}.1";
        description = "Gateway's IP address on the tunnel";
      };
    };
  };

  config = mkMerge [
    # Gateway configuration
    (mkIf cfg.gateway.enable {
      # Enable IP forwarding
      boot.kernel.sysctl = {
        "net.ipv4.ip_forward" = 1;
      };

      # Static IP on tunnel interface via NetworkManager
      networking.networkmanager.ensureProfiles.profiles = {
        ethernet-share-gateway = {
          connection = {
            id = "ethernet-share-gateway";
            type = "ethernet";
            interface-name = cfg.gateway.interface;
            autoconnect = true;
          };
          ipv4 = {
            method = "manual";
            addresses = "${cfg.gateway.ip}/24";
          };
          ipv6 = {
            method = "disabled";
          };
        };
      };

      # NAT masquerade for traffic from tunnel subnet
      networking.firewall.extraCommands = ''
        # Masquerade traffic from the ethernet-share subnet
        iptables -t nat -C POSTROUTING -s ${subnet}.0/24 ! -d ${subnet}.0/24 -j MASQUERADE 2>/dev/null || \
        iptables -t nat -A POSTROUTING -s ${subnet}.0/24 ! -d ${subnet}.0/24 -j MASQUERADE
      '';

      networking.firewall.extraStopCommands = ''
        iptables -t nat -D POSTROUTING -s ${subnet}.0/24 ! -d ${subnet}.0/24 -j MASQUERADE 2>/dev/null || true
      '';

      # Allow forwarding from tunnel interface
      networking.firewall.trustedInterfaces = [ cfg.gateway.interface ];
    })

    # Client configuration
    (mkIf cfg.client.enable {
      # Static IP on tunnel interface via NetworkManager
      networking.networkmanager.ensureProfiles.profiles = {
        ethernet-share-client = {
          connection = {
            id = "ethernet-share-client";
            type = "ethernet";
            interface-name = cfg.client.interface;
            autoconnect = true;
          };
          ipv4 = {
            method = "manual";
            addresses = "${cfg.client.ip}/24";
            gateway = cfg.client.gatewayIP;
            dns = "8.8.8.8;1.1.1.1";
            route-metric = "50";  # Prefer this route over others
          };
          ipv6 = {
            method = "disabled";
          };
        };
      };
    })
  ];
}
