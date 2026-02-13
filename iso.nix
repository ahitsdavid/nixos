# ISO configuration for NixOS installer
# Boots into GNOME desktop with the repo and install wizard ready to go
{ config, pkgs, lib, inputs, username, ... }:

{
  imports = [
    "${inputs.nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"

    # Include specific modules we need (excluding bootloader which conflicts with ISO)
    (import ./profiles/base/users.nix { inherit inputs username; })
    (import ./profiles/base/nix-config.nix { inherit inputs username; })
  ];

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.allowBroken = true;

  # ISO-specific configuration
  isoImage.squashfsCompression = "gzip -Xcompression-level 1";

  # Enable support for multiple filesystems
  boot.supportedFilesystems = lib.mkForce [
    "ext4"     # Standard Linux filesystem
    "btrfs"    # Advanced filesystem with snapshots
    "xfs"      # High-performance filesystem
    "f2fs"     # Flash-friendly filesystem for SSDs
    "ntfs"     # Windows compatibility
    "exfat"    # Cross-platform compatibility
    "vfat"     # Boot partition standard
    "bcachefs" # Next-generation COW filesystem
  ];

  # GNOME-only desktop (no Hyprland)
  services.xserver.enable = true;
  services.desktopManager.gnome.enable = true;
  services.displayManager.gdm.enable = true;
  services.displayManager.gdm.wayland = true;

  # Add filesystem tools, utilities, and install wizard
  environment.systemPackages = with pkgs; [
    # Essential tools
    git
    curl
    wget
    vim
    nano
    htop

    # Hardware detection
    pciutils
    usbutils
    lshw

    # Network tools
    networkmanager

    # Partitioning tools
    parted
    gparted
    util-linux  # provides cfdisk
    gptfdisk    # provides gdisk

    # Filesystem tools
    e2fsprogs     # ext4
    btrfs-progs   # btrfs
    xfsprogs      # xfs
    f2fs-tools    # f2fs
    ntfs3g        # ntfs
    exfatprogs    # exfat
    dosfstools    # fat
    bcachefs-tools # bcachefs

    # Encryption
    cryptsetup

    # LVM
    lvm2

    # GPU utilities
    mesa-demos

    # GNOME terminal for easy script access
    gnome-terminal

    # Install wizard wrapper
    (pkgs.writeShellScriptBin "nixos-install-wizard" ''
      exec /etc/nixos-config/scripts/install.sh "$@"
    '')
  ];

  # Bake in the full repo so install.sh is available on boot
  environment.etc."nixos-config".source = ./.;

  # Enable SSH for remote installation if needed
  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = true;
    settings.PermitRootLogin = "yes";
  };

  # Override the default passwords with lib.mkForce
  users.users.root.initialPassword = lib.mkForce "nixos";
  users.users.nixos.initialPassword = lib.mkForce "nixos";

  # Enable networkmanager for easier network setup
  networking.networkmanager.enable = true;
  networking.wireless.enable = lib.mkForce false;

  # Hardware configuration hints
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  system.stateVersion = "25.05";
}
