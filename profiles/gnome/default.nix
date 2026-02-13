# profiles/gnome/default.nix
# Core GNOME desktop profile — shared by all GNOME hosts
{ config, lib, pkgs, ... }:
{
  # Disable Hyprland (base profile enables via mkDefault)
  programs.hyprland.enable = lib.mkForce false;

  # GNOME Desktop
  services.xserver.enable = true;
  services.desktopManager.gnome.enable = true;

  # Switch from SDDM to GDM (mkOverride 60 so hosts can mkForce override)
  services.displayManager.gdm.enable = lib.mkOverride 60 true;
  services.displayManager.gdm.wayland = lib.mkDefault true;
  services.displayManager.sddm.enable = lib.mkOverride 60 false;

  # Override portal config for GNOME
  xdg.portal.config.hyprland.default = lib.mkForce [];
  systemd.user.services.xdg-desktop-portal-gtk.wantedBy = lib.mkForce [];

  # GNOME power management — override laptop's TLP default
  # Uses mkOverride 60 so hosts like work-intel can mkForce TLP back on
  services.power-profiles-daemon.enable = lib.mkOverride 60 true;
  services.tlp.enable = lib.mkOverride 60 false;

  # Exclude GNOME bloat
  environment.gnome.excludePackages = with pkgs; [
    gnome-tour epiphany geary gnome-music
  ];
}
