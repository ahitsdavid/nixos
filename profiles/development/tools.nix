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
    xorg.xhost    # X11 access control for Docker GUI apps
    xorg.xauth    # X11 authentication for Docker GUI apps

    # Docker utilities
    lazydocker    # TUI for Docker management
    dive          # Explore Docker image layers
  ];

  virtualisation = {
    libvirtd.enable = true;
    docker.enable = true;
    podman.enable = true;  # Enabled for distrobox
  };

  # Enable X11 forwarding for Docker GUI apps
  services.xserver.enable = true;
  services.displayManager.gdm.enable = false; # We use greetd, not GDM

  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;

}