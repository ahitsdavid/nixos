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
    (import ./modules/rofi )
    
  ];
  
  # Packages for user
  home.packages = with pkgs; [
    bitwarden
    spotify
    oh-my-posh
    telegram-desktop
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

  home.sessionVariables = {
    EDITOR = "nvim";
    BROWSER = "firefox";
    TERMINAL = "kitty";
  };

  programs = {
    home-manager.enable = true;

    git = {
      enable = true;
      userName = "David Thach";
      userEmail = "davidthach@live.com";
      extraConfig = {
        init.defaultBranch = "main";
      };
    };
  };

  home.stateVersion = "25.11";
}
