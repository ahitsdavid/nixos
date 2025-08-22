#home/modules/thunar.nix
{ pkgs, lib, ... }:
{
  gtk = {
    enable = true;
    iconTheme = {
      name = "Papirus-Dark";
      package = lib.mkDefault pkgs.papirus-icon-theme;
    };
  };

  xdg.enable = true;
  # Add useful Thunar plugins
  home.packages = with pkgs.xfce; [
    thunar
    thunar-volman      # Removable media management
    thunar-archive-plugin  # Archive support
    thunar-media-tags-plugin  # Media file tags
    tumbler
  ];
}