{pkgs, lib, config, username, ...}:
let
  cfg = config.services.displayManager.sddm;

  # Wallpaper source from repo
  wallpaperSrc = ../../wallpapers/yosemite.png;

  # Base catppuccin theme
  catppuccinBase = pkgs.catppuccin-sddm.override {
    flavor = "mocha";
    accent = "mauve";
  };

  # Custom SDDM theme - overlay our components on catppuccin base
  catppuccin-rounded-sddm = pkgs.stdenv.mkDerivation {
    pname = "sddm-catppuccin-rounded";
    version = "1.0";

    src = ./sddm-theme;

    installPhase = ''
      mkdir -p $out/share/sddm/themes/catppuccin-rounded

      # Start with catppuccin base theme
      cp -r ${catppuccinBase}/share/sddm/themes/catppuccin-mocha-mauve/* $out/share/sddm/themes/catppuccin-rounded/
      chmod -R u+w $out/share/sddm/themes/catppuccin-rounded/

      # Override with our custom files
      cp $src/Main.qml $out/share/sddm/themes/catppuccin-rounded/
      cp $src/Components/*.qml $out/share/sddm/themes/catppuccin-rounded/Components/

      # Update metadata
      cp $src/metadata.desktop $out/share/sddm/themes/catppuccin-rounded/

      # Copy wallpaper into theme
      cp ${wallpaperSrc} $out/share/sddm/themes/catppuccin-rounded/background.png

      # Update theme.conf with relative wallpaper path
      cat > $out/share/sddm/themes/catppuccin-rounded/theme.conf << EOF
[General]
Background="background.png"
Font="Rubik"
FontSize=12
EOF
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
    settings = {
      General = {
        DefaultSession = "hyprland.desktop";
      };
    };
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
