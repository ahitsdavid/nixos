#home/modules/thunar.nix
{ pkgs, ... }:
{
  gtk = {
    enable = true;
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
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