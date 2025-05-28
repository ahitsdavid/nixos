{ config, pkgs, lib, username, ... }:

with lib;

let
  cfg = config.services.gdm-customization;
  
  # Package the face script properly with bash dependency
  gdmFaceScript = pkgs.runCommand "setup-gdm-face" {
    script = ./scripts/setup-face.sh;
    buildInputs = [ pkgs.makeWrapper ];
  } ''
    mkdir -p $out/bin
    cp $script $out/bin/setup-gdm-face
    chmod +x $out/bin/setup-gdm-face
    wrapProgram $out/bin/setup-gdm-face --prefix PATH : ${lib.makeBinPath [ pkgs.bash pkgs.coreutils ]}
  '';
in {
  options.services.gdm-customization = {
    enable = mkEnableOption "GDM customization (profile picture)";
    
    session = mkOption {
      type = types.str;
      default = "hyprland";
      description = "The session name to use in the AccountsService user file";
    };

    face = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Whether to enable profile picture customization";
      };
    };
  };

  config = mkIf cfg.enable {
    services.accounts-daemon.enable = true;
    
    # Service for face icon (kept from original since it works)
    systemd.services.setup-gdm-face = mkIf cfg.face.enable {
      description = "Setup GDM face icon";
      wantedBy = [ "multi-user.target" ];
      after = [ "accounts-daemon.service" ];
      path = with pkgs; [ bash coreutils ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${gdmFaceScript}/bin/setup-gdm-face ${username} ${cfg.session}";
        ExecStartPost = "${pkgs.systemd}/bin/systemctl restart accounts-daemon.service";
      };
    };
  };
}
