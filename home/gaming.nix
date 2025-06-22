# home/gaming.nix
{ config, pkgs, inputs, ... }: {
  home.packages = with pkgs; [
    prismlauncher
  ];

  programs.mangohud = {
    enable = false;
    enableSessionWide = true;
  };
}