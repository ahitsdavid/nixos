#home/modules/xdg.nix 
{ pkgs, ... } :
{
  xdg.portal = {
    enable = true;
    xdgOpenUsePortal= true;
    config = {
        common.default = ["gtk"];
        hyprland.default = ["hyprland" "gtk"];
    };
    extraPortals = with pkgs; [
        xdg-desktop-portal-gtk
    ];
  };
}