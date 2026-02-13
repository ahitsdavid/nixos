{ config, pkgs, inputs, username, lib, ... }: {
  imports = [
    ./hardware-configuration.nix

    # Waydroid - uses Intel iGPU for proper GPU acceleration
    ../../core/modules/waydroid.nix
  ];

  # Kernel - latest for best NVIDIA support
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Override: use power-profiles-daemon instead of TLP
  services.tlp.enable = false;
  services.power-profiles-daemon.enable = true;

  # Override: disable thermald (NVIDIA handles its own thermals)
  services.thermald.enable = false;

  # Hardware acceleration for gaming
  hardware.graphics = {
    enable = true;
    enable32Bit = true; # Required for 32-bit games/Steam
  };

  # Legion-specific packages
  environment.systemPackages = with pkgs; [
    usbutils
  ];

  networking.hostName = "legion";

  # Ethernet sharing - can be gateway (when docked) or client (when work-intel is docked)
  networking.ethernet-share.gateway = {
    enable = false;
    interface = "enp66s0";
  };
  networking.ethernet-share.client = {
    enable = true;
    interface = "enp66s0";
  };

  # stateVersion: Set at initial install - do not change
  system.stateVersion = "25.05";
}
