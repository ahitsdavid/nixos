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
    (import ./modules/ssh.nix )
    (import ./modules/bitwarden.nix )

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

    # Local media player
    mpv  # Lightweight video player for MKV and other formats

    # Photo editing and RAW file management
    darktable  # Professional RAW photo workflow application
    gimp  # General-purpose image editor with RAW support
    digikam  # Professional photo management with RAW support
    shotwell  # Photo manager with RAW support

    # Note-taking
    obsidian  # Markdown-based knowledge base
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

  # Set Firefox as default browser for all web links
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "text/html" = "firefox.desktop";
      "x-scheme-handler/http" = "firefox.desktop";
      "x-scheme-handler/https" = "firefox.desktop";
      "x-scheme-handler/about" = "firefox.desktop";
      "x-scheme-handler/unknown" = "firefox.desktop";
    };
  };

  home.stateVersion = "25.11";
}
