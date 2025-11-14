# ISO configuration for desktop installation
{ config, pkgs, lib, inputs, username, ... }:

{
  imports = [
    "${inputs.nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
    
    # Include specific modules we need (excluding bootloader which conflicts with ISO)
    (import ./profiles/base/users.nix { inherit inputs username; })
    (import ./profiles/base/nix-config.nix { inherit inputs; })
    
    # Include Nvidia drivers for hardware detection
    ./core/drivers/nvidia.nix
  ];

  # Allow unfree packages (needed for Nvidia drivers)
  nixpkgs.config.allowUnfree = true;

  # Enable Nvidia drivers in ISO
  drivers.nvidia.enable = true;

  # ISO-specific configuration
  isoImage.squashfsCompression = "gzip -Xcompression-level 1";
  
  # Enable support for multiple filesystems
  boot.supportedFilesystems = [
    "ext4"     # Standard Linux filesystem
    "btrfs"    # Advanced filesystem with snapshots
    "xfs"      # High-performance filesystem
    "f2fs"     # Flash-friendly filesystem for SSDs
    "zfs"      # Advanced filesystem with built-in RAID
    "ntfs"     # Windows compatibility
    "exfat"    # Cross-platform compatibility
    "fat32"    # Boot partition standard
    "bcachefs" # Next-generation COW filesystem
  ];

  # ZFS support
  boot.zfs.forceImportRoot = false;
  
  # Add filesystem tools and utilities
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
    # ext4
    e2fsprogs
    
    # btrfs
    btrfs-progs
    
    # xfs
    xfsprogs
    
    # f2fs
    f2fs-tools
    
    # zfs
    zfs
    
    # ntfs/exfat/fat
    ntfs3g
    exfatprogs
    dosfstools
    
    # bcachefs
    bcachefs-tools
    
    # Encryption
    cryptsetup
    
    # LVM
    lvm2

    # GPU utilities
    mesa-demos
    nvidia-vaapi-driver
    nvtopPackages.full
  ];

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
  networking.wireless.enable = false;

  # Enable Hyprland for a graphical environment during installation
  programs.hyprland = {
    enable = true;
    package = inputs.hyprland.packages.${pkgs.system}.hyprland;
  };

  # Enable X11 and display manager for installation GUI
  services.xserver.enable = true;
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

  # Hardware configuration hints for desktop
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  # Include our desktop configuration as a reference
  environment.etc."nixos-desktop-config" = {
    source = ./hosts/desktop;
    target = "nixos/desktop-config";
  };

  # Add installation helper script with filesystem options
  environment.etc."install-desktop.sh" = {
    text = ''
      #!/usr/bin/env bash
      echo "NixOS Desktop Installation Helper"
      echo "This script will help you install NixOS with the desktop configuration"
      echo ""
      echo "Available configurations:"
      echo "- Desktop (Nvidia 3070Ti + Intel i7-8700K + Hyprland)"
      echo ""
      echo "Supported filesystems:"
      echo "- ext4: Standard, reliable Linux filesystem"
      echo "- btrfs: Advanced with snapshots, compression, RAID"
      echo "- xfs: High-performance for large files"
      echo "- f2fs: Optimized for SSDs and flash storage"
      echo "- zfs: Enterprise-grade with built-in RAID, snapshots, dedup"
      echo "- bcachefs: Next-gen copy-on-write filesystem"
      echo ""
      echo "Configuration files are located in /etc/nixos/desktop-config/"
      echo ""
      echo "To install:"
      echo "1. Partition your disks (use cfdisk, gdisk, or gparted)"
      echo "2. Format with your chosen filesystem:"
      echo "   - ext4: mkfs.ext4 /dev/sdXY"
      echo "   - btrfs: mkfs.btrfs /dev/sdXY"
      echo "   - xfs: mkfs.xfs /dev/sdXY"
      echo "   - f2fs: mkfs.f2fs /dev/sdXY"
      echo "   - zfs: zpool create rpool /dev/sdXY"
      echo "   - bcachefs: bcachefs format /dev/sdXY"
      echo "3. Mount your filesystems to /mnt"
      echo "4. Copy desktop config: cp -r /etc/nixos/desktop-config/* /mnt/etc/nixos/"
      echo "5. Generate hardware config: nixos-generate-config --root /mnt"
      echo "6. Edit /mnt/etc/nixos/hardware-configuration.nix if needed"
      echo "7. Install: nixos-install --flake /mnt/etc/nixos#desktop"
    '';
    mode = "0755";
  };

  system.stateVersion = "25.05";
}