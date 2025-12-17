# core/modules/nextcloud.nix
{ pkgs, config, ... }: {
  # Enable Nextcloud service
  services.nextcloud = {
    enable = true;
    package = pkgs.nextcloud30;
    hostName = "localhost";

    # Database configuration
    database.createLocally = true;

    # Basic configuration
    config = {
      dbtype = "pgsql";
      adminpassFile = "/etc/nextcloud-admin-pass";
      adminuser = "admin";
    };

    # Enable HTTPS (you can disable this if running behind a reverse proxy)
    https = false;

    # Auto-update apps
    autoUpdateApps.enable = true;

    # Performance settings
    maxUploadSize = "16G";
    phpOptions = {
      "opcache.interned_strings_buffer" = "16";
    };
  };

  # Open firewall for Nextcloud
  networking.firewall.allowedTCPPorts = [ 80 443 ];
}
