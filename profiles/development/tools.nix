# profiles/development/tools.nix
{ inputs }:
{ config, pkgs, ... }: {

  # Common development packages
  environment.systemPackages = with pkgs; [
    gh # Github CLI
    jq
    yq
    ripgrep
    fd
    bat
    tmux
    direnv
  ];

  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;

}