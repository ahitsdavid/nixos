# profiles/development/containers.nix
{ inputs }:
{ config, pkgs, lib, ... }:
let
  username = config.users.users.davidthach.name or "davidthach";
in
{
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

  # Declaratively create Arch distrobox container
  systemd.user.services.distrobox-arch = {
    description = "Distrobox Arch Linux Container";
    wantedBy = [ "default.target" ];
    after = [ "podman.service" ];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = let
        createScript = pkgs.writeShellScript "create-arch-distrobox" ''
          # Check if container already exists
          if ! ${pkgs.distrobox}/bin/distrobox list | grep -q "arch"; then
            echo "Creating Arch distrobox container..."
            ${pkgs.distrobox}/bin/distrobox create \
              --name arch \
              --image archlinux:latest \
              --yes
          else
            echo "Arch distrobox container already exists"
          fi
        '';
      in "${createScript}";
    };
  };

  # Auto-setup yay and essential packages in Arch container
  systemd.user.services.distrobox-arch-setup = {
    description = "Setup Arch distrobox with yay";
    after = [ "distrobox-arch.service" ];
    wantedBy = [ "default.target" ];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = let
        setupScript = pkgs.writeShellScript "setup-arch-distrobox" ''
          # Check if yay is already installed
          if ! ${pkgs.distrobox}/bin/distrobox enter arch -- which yay &>/dev/null; then
            echo "Setting up yay in Arch container..."
            ${pkgs.distrobox}/bin/distrobox enter arch -- bash -c '
              sudo pacman -S --needed --noconfirm git base-devel
              cd /tmp
              git clone https://aur.archlinux.org/yay.git
              cd yay
              makepkg -si --noconfirm
              cd ..
              rm -rf yay
            '
          else
            echo "yay already installed in Arch container"
          fi
        '';
      in "${setupScript}";
    };
  };
}
