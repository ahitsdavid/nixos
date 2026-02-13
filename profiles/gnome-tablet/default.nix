# profiles/gnome-tablet/default.nix
# GNOME optimized for tablet/touch use
{ config, lib, pkgs, ... }:
{
  imports = [ ../gnome ];

  # Force GDM for tablet reliability (override gnome profile's mkOverride 60)
  services.displayManager.gdm.enable = lib.mkForce true;
  services.displayManager.sddm.enable = lib.mkForce false;

  # Extra tablet bloat exclusions (on top of gnome profile's list)
  environment.gnome.excludePackages = with pkgs; [
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

  # Enable gnome-keyring for credential storage
  services.gnome.gnome-keyring.enable = true;

  # Force power-profiles-daemon for tablet, disable TLP
  services.power-profiles-daemon.enable = lib.mkForce true;
  services.tlp.enable = lib.mkForce false;
}
