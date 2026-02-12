# home/minimal.nix
# Minimal home config for GNOME hosts (no Hyprland/QuickShell)
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
    ./modules/foot.nix       # Foot terminal (lightweight, Wayland-native)
    ./modules/fastfetch
    ./modules/chromium.nix
    ./modules/ssh.nix
    ./modules/bitwarden.nix
    ./modules/syncthing.nix
    ./modules/claude.nix
    ./modules/git.nix
    ./modules/eza.nix
    ./modules/nixvim.nix
    ./modules/yazi.nix
    ./modules/btop.nix
    ./modules/catppuccin.nix
    ./modules/stylix.nix
    ./modules/sops-manager.nix
    # Excluded: hyprland/, quickshell, kitty, spicetify, obs, vscode, zed, thunar
  ];

  # Packages for user (minimal set for tablet use)
  home.packages = with pkgs; [
    bitwarden-desktop
    telegram-desktop
    localsend
    obsidian

    # Media players for Unraid server
    plex-desktop
    jellyfin-media-player

    # Local media player
    mpv
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
