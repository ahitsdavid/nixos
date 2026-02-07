# lib/package-sets.nix - Grouped package definitions
# Use: let sets = import ../../lib/package-sets.nix { inherit pkgs; };
#      environment.systemPackages = sets.monitoring ++ sets.graphics;
{ pkgs }:
{
  # System monitoring and diagnostics
  monitoring = with pkgs; [
    htop
    lm_sensors
  ];

  # Laptop-specific monitoring (extends monitoring)
  laptopMonitoring = with pkgs; [
    powertop
    acpi
  ];

  # Graphics baseline (Mesa, Vulkan)
  graphics = with pkgs; [
    mesa
    mesa-demos
    vulkan-tools
    vulkan-loader
  ];

  # Archive and compression tools
  archive = with pkgs; [
    unzip
    unrar
    zip
  ];

  # System inspection utilities
  system = with pkgs; [
    file
    lshw
    pciutils
    usbutils
    tree
  ];

  # Network utilities
  network = with pkgs; [
    curl
    wget
    rsync
  ];

  # Development basics
  dev = with pkgs; [
    git
    jq
  ];

  # Disk and partition tools
  disk = with pkgs; [
    parted
    gptfdisk
    efibootmgr
  ];

  # Audio utilities
  audio = with pkgs; [
    lxqt.pavucontrol-qt
  ];
}
