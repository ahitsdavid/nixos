{ config, lib, pkgs, ... }:

{
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;

    # SSH client configuration
    matchBlocks = {
      "unraid" = {
        hostname = "192.168.1.29";
        user = "root";
        identityFile = "${config.home.homeDirectory}/.ssh/unraid_rsa";
        # Disable strict host key checking for local network (optional - remove if you prefer strict checking)
        extraOptions = {
          "StrictHostKeyChecking" = "accept-new";
        };
      };
    };
  };

  # Ensure .ssh directory exists with correct permissions
  home.file.".ssh/.keep" = {
    text = "";
    onChange = ''
      chmod 700 ${config.home.homeDirectory}/.ssh
    '';
  };
}
