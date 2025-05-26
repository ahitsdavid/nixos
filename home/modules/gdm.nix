{ config, pkgs, lib, username, ... }:

with lib;

let
  cfg = config.services.gdm-face;
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
    
    systemd.services.setup-gdm-face = {
      description = "Setup GDM face icon";
      wantedBy = [ "multi-user.target" ];
      after = [ "accounts-daemon.service" ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = pkgs.writeShellScript "copy-face-icon" ''
          # Create required directories
          mkdir -p /var/lib/AccountsService/icons
          mkdir -p /var/lib/AccountsService/users
          
          # Copy the actual file content, not the symlink
          if [ -L "/home/${username}/.face" ]; then
            # Get the target of the symlink and copy it
            cp -L "/home/${username}/.face" "/var/lib/AccountsService/icons/${username}"
          elif [ -f "/home/${username}/.face" ]; then
            # Direct copy if it's a regular file
            cp "/home/${username}/.face" "/var/lib/AccountsService/icons/${username}"
          fi
          
          # Set proper permissions
          chmod 644 "/var/lib/AccountsService/icons/${username}"
          chown root:root "/var/lib/AccountsService/icons/${username}"
          
          # Create or update the user file
          cat > "/var/lib/AccountsService/users/${username}" << EOF
          [User]
          Session=${cfg.session}
          Icon=/var/lib/AccountsService/icons/${username}
          SystemAccount=false
          EOF
          
          chmod 644 "/var/lib/AccountsService/users/${username}"
          chown root:root "/var/lib/AccountsService/users/${username}"
          
          # Restart accounts-daemon to apply changes
          ${pkgs.systemd}/bin/systemctl restart accounts-daemon.service
        '';
      };
    };
    
    system.activationScripts.gdmUserIcon = lib.stringAfter [ "users" ] ''
      # Create required directories
      mkdir -p /var/lib/AccountsService/icons
      mkdir -p /var/lib/AccountsService/users
      
      # Copy the actual file content, not the symlink
      if [ -L "/home/${username}/.face" ]; then
        # Get the target of the symlink and copy it
        cp -L "/home/${username}/.face" "/var/lib/AccountsService/icons/${username}"
      elif [ -f "/home/${username}/.face" ]; then
        # Direct copy if it's a regular file
        cp "/home/${username}/.face" "/var/lib/AccountsService/icons/${username}"
      fi
      
      # Set proper permissions
      chmod 644 "/var/lib/AccountsService/icons/${username}"
      chown root:root "/var/lib/AccountsService/icons/${username}"
      
      # Create or update the user file
      cat > "/var/lib/AccountsService/users/${username}" << EOF
      [User]
      Session=${cfg.session}
      Icon=/var/lib/AccountsService/icons/${username}
      SystemAccount=false
      EOF
      
      chmod 644 "/var/lib/AccountsService/users/${username}"
      chown root:root "/var/lib/AccountsService/users/${username}"
    '';
  };
}
