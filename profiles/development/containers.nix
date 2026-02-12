# profiles/development/containers.nix
{ inputs, username }:
{ config, pkgs, lib, ... }:
let
  # Declarative package lists for Arch container
  # These packages will be installed if not present, but never removed
  # This provides a reproducible foundation while allowing manual package additions
  archPackages = [
    # Base development tools
    "git"
    "base-devel"

    # System utilities
    "fastfetch"

    # Qt6 Development Environment
    "qt6-base"           # Qt6 core libraries
    "qt6-tools"          # Qt6 development tools (qmake, etc.)
    "qt6-declarative"    # Qt Quick/QML
    "qt6-wayland"        # Qt6 Wayland plugin (required for GUI on Wayland)
    "xorg-server-xwayland"  # XWayland for X11 app compatibility
    "cmake"              # Build system
    "ninja"              # Fast build tool (optional, used by CMake)
    "clang"              # C++ compiler + clangd LSP
    "gdb"                # Debugger
    "qt6-doc"            # Qt documentation (optional)

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
      Environment = "PATH=/run/current-system/sw/bin";
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
      Environment = "PATH=/run/current-system/sw/bin";
      ExecStart = let
        # Convert package lists to space-separated strings
        archPkgs = lib.concatStringsSep " " archPackages;
        aurPkgs = lib.concatStringsSep " " aurPackages;

        # Custom fastfetch config showing both NixOS and Arch
        fastfetchConfig = pkgs.writeText "fastfetch-arch.jsonc" ''
          {
            "$schema": "https://github.com/fastfetch-cli/fastfetch/raw/dev/doc/json_schema.json",
            "logo": {
              "type": "builtin",
              "source": "arch"
            },
            "display": {
              "separator": " ➜  "
            },
            "modules": [
              {
                "type": "title",
                "format": "{user-name-colored}@{host-name-colored}"
              },
              {
                "type": "separator"
              },
              {
                "type": "custom",
                "format": "Host OS: NixOS → Container: Arch Linux"
              },
              "os",
              "kernel",
              "packages",
              "shell",
              "display",
              "de",
              "wm",
              "theme",
              "icons",
              "terminal",
              "cpu",
              "gpu",
              "memory",
              "disk",
              "uptime"
            ]
          }
        '';

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

          # Setup custom fastfetch config for Arch container
          echo "Setting up custom fastfetch config..."
          ${pkgs.distrobox}/bin/distrobox enter arch -- \
            sudo mkdir -p /etc/fastfetch
          cat ${fastfetchConfig} | ${pkgs.distrobox}/bin/distrobox enter arch -- \
            sudo tee /etc/fastfetch/config.jsonc > /dev/null

          # Create alias for easy use in home directory config
          ${pkgs.distrobox}/bin/distrobox enter arch -- bash -c '
            touch ~/.bashrc 2>/dev/null || true
            if ! grep -q "alias ff=" ~/.bashrc 2>/dev/null; then
              echo "alias ff=\"fastfetch --config /etc/fastfetch/config.jsonc\"" >> ~/.bashrc
            fi
          '

          echo "Arch container setup complete!"
        '';
      in "${setupScript}";
    };
  };
}
