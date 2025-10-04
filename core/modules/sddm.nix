{pkgs, lib, config, username, ...}:
let
  cfg = config.services.displayManager.sddm;
  wallpaperPath = null; # Set to a path string to override theme wallpaper, e.g., "/path/to/wallpaper.jpg"
in
{
  # Login Environment
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
    theme = "catppuccin-mocha-mauve";
    package = pkgs.kdePackages.sddm;
  };

  environment.systemPackages = [
    (pkgs.catppuccin-sddm.override {
      flavor = "mocha";
      accent = "mauve";
      background = if wallpaperPath != null then wallpaperPath else "";
    })
  ];

}
