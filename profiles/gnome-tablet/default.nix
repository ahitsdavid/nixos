# profiles/gnome-tablet/default.nix
# GNOME optimized for tablet/touch use
{ config, lib, pkgs, ... }:
{
  # Disable Hyprland (from base profile)
  programs.hyprland.enable = lib.mkForce false;

  # GNOME Desktop with GDM (better touch support than SDDM)
  services.xserver.enable = true;
  services.desktopManager.gnome.enable = true;
  services.displayManager.gdm.enable = lib.mkForce true;
  services.displayManager.gdm.wayland = true;

  # Disable SDDM (from display-manager profile)
  services.displayManager.sddm.enable = lib.mkForce false;

  # Override portal config for GNOME
  xdg.portal.config.hyprland.default = lib.mkForce [];

  # Disable the Hyprland-specific portal service
  systemd.user.services.xdg-desktop-portal-gtk.wantedBy = lib.mkForce [];

  # Minimal GNOME - exclude bloat
  environment.gnome.excludePackages = with pkgs; [
    gnome-tour
    epiphany
    geary
    gnome-music
    gnome-contacts
    gnome-maps
    gnome-weather
    gnome-calendar
    totem
    yelp
  ];

  # Touch-optimized tools and extensions
  environment.systemPackages = with pkgs; [
    gnome-tweaks
    gnome-extension-manager
    dconf-editor
    gnomeExtensions.caffeine
    gnomeExtensions.appindicator
    catppuccin-gtk
    catppuccin-papirus-folders
    papirus-icon-theme
  ];

  # Screen rotation sensor support
  hardware.sensor.iio.enable = true;

  # Enable gnome-keyring for credential storage
  services.gnome.gnome-keyring.enable = true;

  # GNOME requires power-profiles-daemon, not TLP
  services.power-profiles-daemon.enable = lib.mkForce true;
  services.tlp.enable = lib.mkForce false;
}
