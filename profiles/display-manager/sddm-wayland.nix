# SDDM with Wayland backend
# Used by: desktop, thinkpad, legion, sb1
{ pkgs, lib, config, username, ... }:
let
  # Wallpaper source from repo
  wallpaperSrc = ../../wallpapers/yosemite.png;

  # Base catppuccin theme
  catppuccinBase = pkgs.catppuccin-sddm.override {
    flavor = "mocha";
    accent = "mauve";
  };

  # Custom SDDM theme - only override visual components, keep working session handling
  catppuccin-styled-sddm = pkgs.stdenv.mkDerivation {
    pname = "sddm-catppuccin-styled";
    version = "1.0";

    src = ../../core/modules/sddm-theme;

    installPhase = ''
      mkdir -p $out/share/sddm/themes/catppuccin-styled

      # Start with catppuccin base theme (has working session selection)
      cp -r ${catppuccinBase}/share/sddm/themes/catppuccin-mocha-mauve/* $out/share/sddm/themes/catppuccin-styled/
      chmod -R u+w $out/share/sddm/themes/catppuccin-styled/

      # Override visual components + custom LoginPanel
      cp $src/Main.qml $out/share/sddm/themes/catppuccin-styled/
      cp $src/Components/Clock.qml $out/share/sddm/themes/catppuccin-styled/Components/
      cp $src/Components/LoginPanel.qml $out/share/sddm/themes/catppuccin-styled/Components/

      # Copy wallpaper into theme
      cp ${wallpaperSrc} $out/share/sddm/themes/catppuccin-styled/background.png

      # Update theme.conf
      cat > $out/share/sddm/themes/catppuccin-styled/theme.conf << EOF
[General]
Background="background.png"
CustomBackground="true"
ClockEnabled="true"
Font="Rubik"
FontSize=12
EOF
    '';
  };
in
{
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
    theme = "catppuccin-styled";
    package = pkgs.kdePackages.sddm;
    settings = {
      General = {
        DefaultSession = "hyprland-uwsm.desktop";
      };
    };
  };

  environment.systemPackages = [
    catppuccin-styled-sddm
  ];

  # Fonts for the theme
  fonts.packages = [
    pkgs.rubik
    pkgs.material-symbols
  ];
}
