{ config, pkgs, lib, username, ... }:

with lib;

let
  cfg = config.services.gdm-customization;
  
  # Package the scripts properly with bash dependency
  gdmFaceScript = pkgs.runCommand "setup-gdm-face" {
    script = ./scripts/setup-face.sh;
    buildInputs = [ pkgs.makeWrapper ];
  } ''
    mkdir -p $out/bin
    cp $script $out/bin/setup-gdm-face
    chmod +x $out/bin/setup-gdm-face
    wrapProgram $out/bin/setup-gdm-face --prefix PATH : ${lib.makeBinPath [ pkgs.bash pkgs.coreutils ]}
  '';

  # Handle both string paths and path objects
  wallpaperPath = 
    if cfg.wallpaper.enable then
      if builtins.isPath cfg.wallpaper.path then
        toString cfg.wallpaper.path  # Convert path object to string
      else if builtins.isString cfg.wallpaper.path then
        if lib.hasPrefix "/" cfg.wallpaper.path then
          cfg.wallpaper.path  # Absolute path as string
        else
          toString (./. + "/${cfg.wallpaper.path}")  # Relative path as string
      else ""
    else "";

  # Optionally copy the wallpaper to the nix store
  wallpaperFile = 
    if cfg.wallpaper.enable && cfg.wallpaper.copyToStore && wallpaperPath != ""
    then pkgs.copyPathToStore (builtins.path { 
      path = wallpaperPath; 
      name = "gdm-wallpaper"; 
    })
    else wallpaperPath;

  gdmWallpaperScript = pkgs.runCommand "setup-gdm-wallpaper" {
    script = ./scripts/setup-wallpaper.sh;
    buildInputs = [ pkgs.makeWrapper ];
  } ''
    mkdir -p $out/bin
    cp $script $out/bin/setup-gdm-wallpaper
    chmod +x $out/bin/setup-gdm-wallpaper
    wrapProgram $out/bin/setup-gdm-wallpaper --prefix PATH : ${lib.makeBinPath [ pkgs.bash pkgs.coreutils pkgs.dconf ]}
  '';
in {
  options.services.gdm-customization = {
    enable = mkEnableOption "GDM customization (profile picture and wallpaper)";
    
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

    wallpaper = {
      enable = mkEnableOption "GDM wallpaper customization";
      
      path = mkOption {
        type = with types; either str path;
        default = "";
        example = "wallpapers/background.jpg";
        description = "Path to the wallpaper image (can be a path object, relative path, or absolute path)";
      };

      copyToStore = mkOption {
        type = types.bool;
        default = true;
        description = "Whether to copy the wallpaper to the Nix store for reliability";
      };
    };
  };

  config = mkIf cfg.enable {
    services.accounts-daemon.enable = true;
    
    systemd.services.setup-gdm-face = mkIf cfg.face.enable {
      description = "Setup GDM face icon";
      wantedBy = [ "multi-user.target" ];
      after = [ "accounts-daemon.service" ];
      path = with pkgs; [ bash coreutils ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${gdmFaceScript}/bin/setup-gdm-face ${username} ${cfg.session}";
        ExecStartPost = mkIf (!cfg.wallpaper.enable) "${pkgs.systemd}/bin/systemctl restart accounts-daemon.service";
      };
    };
    
    systemd.services.setup-gdm-wallpaper = mkIf cfg.wallpaper.enable {
      description = "Setup GDM wallpaper";
      wantedBy = [ "multi-user.target" ];
      after = [ "accounts-daemon.service" ] ++ optional cfg.face.enable "setup-gdm-face.service";
      path = with pkgs; [ bash coreutils dconf ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${gdmWallpaperScript}/bin/setup-gdm-wallpaper ${wallpaperFile}";
        ExecStartPost = "${pkgs.systemd}/bin/systemctl restart accounts-daemon.service";
      };
    };
    
    system.activationScripts.gdmCustomization = lib.stringAfter [ "users" ] ''
      ${optionalString cfg.face.enable "${gdmFaceScript}/bin/setup-gdm-face ${username} ${cfg.session}"}
      ${optionalString cfg.wallpaper.enable "${gdmWallpaperScript}/bin/setup-gdm-wallpaper ${wallpaperFile}"}
    '';
  };
}
