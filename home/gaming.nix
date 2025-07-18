# home/gaming.nix
{ config, pkgs, inputs, ... }: {
  home.packages = with pkgs; [
  ];

  programs.mangohud = {
    enable = false;
    enableSessionWide = true;
  };
}