{ config, pkgs, lib, username, ... }:

with lib;

let
  cfg = config.services.gdm-face;
  
  # Package the script
  gdmFaceScript = pkgs.writeScriptBin "setup-gdm-face" (builtins.readFile ./scripts/setup-face.sh);
in {
  options.services.gdm-face = {
    enable = mkEnableOption "GDM profile picture support";
    
    session = mkOption {
      type = types.str;
      default = "hyprland";
      description = "The session name to use in the AccountsService user file";
    };
  };

  config = mkIf cfg.enable {
    services.accounts-daemon.enable = true;
    
    # Add the script to the system packages
    environment.systemPackages = [ gdmFaceScript ];
    
    systemd.services.setup-gdm-face = {
      description = "Setup GDM face icon";
      wantedBy = [ "multi-user.target" ];
      after = [ "accounts-daemon.service" ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${gdmFaceScript}/bin/setup-gdm-face ${username} ${cfg.session}";
        ExecStartPost = "${pkgs.systemd}/bin/systemctl restart accounts-daemon.service";
      };
    };
    
    system.activationScripts.gdmUserIcon = lib.stringAfter [ "users" ] ''
      ${gdmFaceScript}/bin/setup-gdm-face ${username} ${cfg.session}
    '';
  };
}
