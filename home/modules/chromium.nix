{ config, pkgs, ... }: {
  # Chromium package with policy configuration
  home.packages = with pkgs; [
    chromium
  ];

  # Enable Avahi for mDNS/DNS-SD service discovery (needed for Chromecast)
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  # Open firewall ports for Chromecast
  networking.firewall = {
    allowedTCPPorts = [ 8008 8009 ]; # Chromecast communication ports
    allowedUDPPorts = [ 5353 ]; # mDNS for device discovery
  };

  # Configure Chromium to not ask about default browser
  home.file.".config/chromium/Default/Preferences" = {
    text = ''
      {
        "browser": {
          "check_default_browser": false,
          "default_browser_setting_enabled": false
        }
      }
    '';
  };
}