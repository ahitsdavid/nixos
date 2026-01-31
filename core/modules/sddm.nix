{pkgs, lib, config, username, ...}:
let
  cfg = config.services.displayManager.sddm;
  # Wallpaper path - should match what's used in quickshell/hyprland
  wallpaperPath = "/home/${username}/Pictures/Wallpapers/yosemite.png";

  # Custom SDDM theme with pill-shaped elements inspired by end-4 quickshell
  catppuccin-rounded-sddm = pkgs.stdenv.mkDerivation {
    pname = "sddm-catppuccin-rounded";
    version = "1.0";

    src = ./sddm-theme;

    installPhase = ''
      mkdir -p $out/share/sddm/themes/catppuccin-rounded
      cp -r $src/* $out/share/sddm/themes/catppuccin-rounded/

      # Update wallpaper path in theme.conf
      substituteInPlace $out/share/sddm/themes/catppuccin-rounded/theme.conf \
        --replace "/home/davidthach/Pictures/Wallpapers/yosemite.png" "${wallpaperPath}"
    '';
  };
in
{
  # Login Environment
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
    theme = "catppuccin-rounded";
    package = pkgs.kdePackages.sddm;
  };

  environment.systemPackages = [
    catppuccin-rounded-sddm
    # Required for GraphicalEffects and Qt5Compat
    pkgs.kdePackages.qt5compat
  ];

  # Ensure Material Symbols font is available for SDDM
  fonts.packages = [
    pkgs.material-symbols
    pkgs.rubik
  ];
}
