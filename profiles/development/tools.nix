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
    qemu
  ];

  virtualisation = {
    libvirtd.enable = true;
    docker.enable = true;
    podman.enable = false;
  };

  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;

}