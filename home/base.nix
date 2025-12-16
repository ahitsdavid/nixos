# home/base.nix
{ config, pkgs, inputs, username, system, lib, ... }: {
  home.username = username;
  home.homeDirectory = "/home/${username}";
  
  imports = [
    (import ./modules/firefox/default.nix )
    (import ./modules/zsh/default.nix )
    (import ./modules/default.nix )
    (import ./modules/hyprland )
    (import ./modules/fastfetch )
    #(import ./modules/rofi )
    (import ./modules/chromium.nix )
    
  ];
  
  # Packages for user
  home.packages = with pkgs; [
    bitwarden-desktop
    # spotify  # Removed - provided by spicetify
    oh-my-posh
    telegram-desktop
    # stremio  # Temporarily disabled due to qtwebengine build issues
    localsend
    peazip  # Archive manager for ZIP, 7Z, and 200+ formats
    openscad  # 3D CAD modeler for generating STL files

    # Media players for Unraid server
    plex-desktop  # Plex desktop client (official)
    jellyfin-media-player  # Jellyfin desktop client
  ];

  # Place Files Inside Home Directory
  home.file = {
    "Pictures/Wallpapers" = {
      source = ../wallpapers;
      recursive = true;
    };
    ".face".source = ./users/${username}/face.png;
    ".face.icon".source = ./users/${username}/face.png;
    ".config/face.jpg".source = ./users/${username}/face.png;
  };

  programs = {
    home-manager.enable = true;

    git = {
      enable = true;
      settings = {
        user.name = "David Thach";
        user.email = "davidthach@live.com";
        init.defaultBranch = "main";
      };
    };
  };

  home.stateVersion = "25.11";
}
