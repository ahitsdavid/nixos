# home/gaming.nix
{ config, pkgs, inputs, ... }: {
  home.packages = with pkgs; [
    prismlauncher
    discord
  ];

  programs.mangohud = {
    enable = true;
    enableSessionWide = true;
  };
}