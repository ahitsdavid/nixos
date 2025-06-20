# home/gaming.nix
{ config, pkgs, inputs, ... }: {
  home.packages = with pkgs; [
    prismlauncher
    steam
  ];

  programs.mangohud = {
    enable = false;
    enableSessionWide = true;
  };
}