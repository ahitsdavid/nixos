# home/gaming.nix
{ config, pkgs, inputs, ... }: {
  home.packages = with pkgs; [
    inputs.pokerogue-app.packages.x86_64-linux.pokerogue-app
  ];

  programs.mangohud = {
    enable = false;
    enableSessionWide = true;
  };
}