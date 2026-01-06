# profiles/development/containers.nix
{ inputs }:
{ config, pkgs, ... }: {

  # Distrobox for managing containers
  environment.systemPackages = with pkgs; [
    distrobox
  ];

  # Podman configuration for distrobox
  virtualisation.podman = {
    enable = true;

    # Enable docker compatibility (distrobox can use podman as docker backend)
    dockerCompat = false;  # Set to true if you want 'docker' command to use podman

    # Recommended for distrobox
    defaultNetwork.settings.dns_enabled = true;
  };

  # Note: Arch distrobox containers can be created imperatively with:
  # distrobox create --name arch --image archlinux:latest
  # distrobox enter arch
  #
  # Inside the container you'll have access to:
  # - pacman for package management
  # - yay (install with: pacman -S --needed git base-devel && git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -si)
  # - GUI apps will work automatically with distrobox
}
