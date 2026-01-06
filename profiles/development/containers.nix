# profiles/development/containers.nix
{ inputs }:
{ config, pkgs, lib, ... }:
let
  username = config.users.users.davidthach.name or "davidthach";

  # Declarative package lists for Arch container
  # These packages will be installed if not present, but never removed
  # This provides a reproducible foundation while allowing manual package additions
  archPackages = [
    # Base development tools
    "git"
    "base-devel"

    # System utilities
    "fastfetch"

    # Add your desired packages here
    # Examples:
    # "neovim"
    # "firefox"
    # "discord"
  ];

  aurPackages = [
    # AUR packages to install via yay
    # Add your desired AUR packages here
    # Examples:
    # "visual-studio-code-bin"
    # "slack-desktop"
  ];
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

  # Auto-setup yay and declarative packages in Arch container
  systemd.user.services.distrobox-arch-setup = {
    description = "Setup Arch distrobox with yay and declarative packages";
    after = [ "distrobox-arch.service" ];
    wantedBy = [ "default.target" ];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = let
        # Convert package lists to space-separated strings
        archPkgs = lib.concatStringsSep " " archPackages;
        aurPkgs = lib.concatStringsSep " " aurPackages;

        setupScript = pkgs.writeShellScript "setup-arch-distrobox" ''
          echo "Setting up Arch container with declarative packages..."

          # Install pacman packages (install-only, never remove)
          if [ -n "${archPkgs}" ]; then
            echo "Installing pacman packages: ${archPkgs}"
            ${pkgs.distrobox}/bin/distrobox enter arch -- \
              sudo pacman -S --needed --noconfirm ${archPkgs}
          fi

          # Install yay if not already installed
          if ! ${pkgs.distrobox}/bin/distrobox enter arch -- which yay &>/dev/null; then
            echo "Installing yay for AUR access..."
            ${pkgs.distrobox}/bin/distrobox enter arch -- bash -c '
              cd /tmp
              git clone https://aur.archlinux.org/yay.git
              cd yay
              makepkg -si --noconfirm
              cd ..
              rm -rf yay
            '
          fi

          # Install AUR packages (install-only, never remove)
          if [ -n "${aurPkgs}" ]; then
            echo "Installing AUR packages: ${aurPkgs}"
            ${pkgs.distrobox}/bin/distrobox enter arch -- \
              yay -S --needed --noconfirm ${aurPkgs}
          fi

          echo "Arch container setup complete!"
        '';
      in "${setupScript}";
    };
  };
}
