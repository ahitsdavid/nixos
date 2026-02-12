# home/base.nix
{ config, pkgs, inputs, username, system, hostname, lib, ... }:
let
  userVars = import ../lib/user-vars.nix username;
in
{
  home.username = username;
  home.homeDirectory = "/home/${username}";
  
  imports = [
    ./modules/host-meta.nix  # Must be first - exposes hostMeta to all modules
    ./modules/firefox
    ./modules/zsh
    ./modules/fish.nix
    ./modules/starship.nix
    ./modules/foot.nix
    ./modules/default.nix
    ./modules/hyprland
    ./modules/fastfetch
    ./modules/chromium.nix
    ./modules/ssh.nix
    ./modules/bitwarden.nix
    ./modules/vnc.nix
    ./modules/syncthing.nix
    ./modules/claude.nix
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
        user.name = userVars.gitUsername;
        user.email = userVars.gitEmail;
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

  # stateVersion: Set at initial install - do not change
  home.stateVersion = "25.11";
}
