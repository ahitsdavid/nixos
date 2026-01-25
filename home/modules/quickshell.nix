{ config, lib, pkgs, inputs, ... }:

let
  # Create a fake venv structure for dots-hyprland scripts
  # The get_keybinds.py script expects ILLOGICAL_IMPULSE_VIRTUAL_ENV to be set
  fakeVenv = pkgs.runCommand "illogical-impulse-fake-venv" {} ''
    mkdir -p $out/bin
    # Create a noop activate script
    echo "# Fake activate script for NixOS" > $out/bin/activate
    # Symlink python to the system python3
    ln -s ${pkgs.python3}/bin/python3 $out/bin/python
  '';
in
{
  # Use the official QuickShell from flake (has polkit support)
  programs.quickshell = {
    enable = true;
    package = inputs.quickshell.packages.${pkgs.system}.default;
    systemd = {
      enable = true;
    };
  };

  # Extend the official systemd service to add environment variables
  # Note: kirigami.unwrapped is needed because the wrapped version doesn't include QML files
  systemd.user.services.quickshell.Service.Environment = [
    "QML2_IMPORT_PATH=${lib.concatStringsSep ":" [
      "${pkgs.libsForQt5.qtgraphicaleffects}/${pkgs.libsForQt5.qtbase.qtQmlPrefix}"
      "${pkgs.qt6.qt5compat}/${pkgs.qt6.qtbase.qtQmlPrefix}"
      "${pkgs.qt6.qtpositioning}/${pkgs.qt6.qtbase.qtQmlPrefix}"
      "${pkgs.kdePackages.syntax-highlighting}/lib/qt-6/qml"
      "${pkgs.kdePackages.kirigami.unwrapped}/lib/qt-6/qml"
    ]}"
    "QML_IMPORT_PATH=${lib.concatStringsSep ":" [
      "${pkgs.libsForQt5.qtgraphicaleffects}/${pkgs.libsForQt5.qtbase.qtQmlPrefix}"
      "${pkgs.qt6.qt5compat}/${pkgs.qt6.qtbase.qtQmlPrefix}"
      "${pkgs.qt6.qtpositioning}/${pkgs.qt6.qtbase.qtQmlPrefix}"
      "${pkgs.kdePackages.syntax-highlighting}/lib/qt-6/qml"
      "${pkgs.kdePackages.kirigami.unwrapped}/lib/qt-6/qml"
    ]}"
    # Fake venv for dots-hyprland scripts (get_keybinds.py needs this)
    "ILLOGICAL_IMPULSE_VIRTUAL_ENV=${fakeVenv}"
    # NVIDIA Wayland environment variables for proper EGL initialization
    "GBM_BACKEND=nvidia-drm"
    "__GLX_VENDOR_LIBRARY_NAME=nvidia"
    "LIBVA_DRIVER_NAME=nvidia"
  ];

  # Add QML import paths as session variables
  home.sessionVariables = {
    QML2_IMPORT_PATH = lib.concatStringsSep ":" [
      "${pkgs.libsForQt5.qtgraphicaleffects}/${pkgs.libsForQt5.qtbase.qtQmlPrefix}"
      "${pkgs.qt6.qt5compat}/${pkgs.qt6.qtbase.qtQmlPrefix}"
      "${pkgs.qt6.qtpositioning}/${pkgs.qt6.qtbase.qtQmlPrefix}"
      "${pkgs.kdePackages.syntax-highlighting}/lib/qt-6/qml"
      "${pkgs.kdePackages.kirigami.unwrapped}/lib/qt-6/qml"
    ];
    QML_IMPORT_PATH = lib.concatStringsSep ":" [
      "${pkgs.libsForQt5.qtgraphicaleffects}/${pkgs.libsForQt5.qtbase.qtQmlPrefix}"
      "${pkgs.qt6.qt5compat}/${pkgs.qt6.qtbase.qtQmlPrefix}"
      "${pkgs.qt6.qtpositioning}/${pkgs.qt6.qtbase.qtQmlPrefix}"
      "${pkgs.kdePackages.syntax-highlighting}/lib/qt-6/qml"
      "${pkgs.kdePackages.kirigami.unwrapped}/lib/qt-6/qml"
    ];
    # Fake venv for dots-hyprland scripts
    ILLOGICAL_IMPULSE_VIRTUAL_ENV = "${fakeVenv}";
  };

  # Also add to shell profile for immediate availability
  programs.bash.sessionVariables = {
    QML2_IMPORT_PATH = lib.concatStringsSep ":" [
      "${pkgs.libsForQt5.qtgraphicaleffects}/${pkgs.libsForQt5.qtbase.qtQmlPrefix}"
      "${pkgs.qt6.qt5compat}/${pkgs.qt6.qtbase.qtQmlPrefix}"
      "${pkgs.qt6.qtpositioning}/${pkgs.qt6.qtbase.qtQmlPrefix}"
      "${pkgs.kdePackages.syntax-highlighting}/lib/qt-6/qml"
      "${pkgs.kdePackages.kirigami.unwrapped}/lib/qt-6/qml"
    ];
    QML_IMPORT_PATH = lib.concatStringsSep ":" [
      "${pkgs.libsForQt5.qtgraphicaleffects}/${pkgs.libsForQt5.qtbase.qtQmlPrefix}"
      "${pkgs.qt6.qt5compat}/${pkgs.qt6.qtbase.qtQmlPrefix}"
      "${pkgs.qt6.qtpositioning}/${pkgs.qt6.qtbase.qtQmlPrefix}"
      "${pkgs.kdePackages.syntax-highlighting}/lib/qt-6/qml"
      "${pkgs.kdePackages.kirigami.unwrapped}/lib/qt-6/qml"
    ];
  };

  # And for zsh if you use it
  programs.zsh.sessionVariables = {
    QML2_IMPORT_PATH = lib.concatStringsSep ":" [
      "${pkgs.libsForQt5.qtgraphicaleffects}/${pkgs.libsForQt5.qtbase.qtQmlPrefix}"
      "${pkgs.qt6.qt5compat}/${pkgs.qt6.qtbase.qtQmlPrefix}"
      "${pkgs.qt6.qtpositioning}/${pkgs.qt6.qtbase.qtQmlPrefix}"
      "${pkgs.kdePackages.syntax-highlighting}/lib/qt-6/qml"
      "${pkgs.kdePackages.kirigami.unwrapped}/lib/qt-6/qml"
    ];
    QML_IMPORT_PATH = lib.concatStringsSep ":" [
      "${pkgs.libsForQt5.qtgraphicaleffects}/${pkgs.libsForQt5.qtbase.qtQmlPrefix}"
      "${pkgs.qt6.qt5compat}/${pkgs.qt6.qtbase.qtQmlPrefix}"
      "${pkgs.qt6.qtpositioning}/${pkgs.qt6.qtbase.qtQmlPrefix}"
      "${pkgs.kdePackages.syntax-highlighting}/lib/qt-6/qml"
      "${pkgs.kdePackages.kirigami.unwrapped}/lib/qt-6/qml"
    ];
  };

  # Install additional packages that QuickShell needs
  home.packages = with pkgs; [
    # System tools
    gammastep
    geoclue2
    playerctl
    wireplumber
    libdbusmenu-gtk3
    ddcutil
    
    # GNOME tools
    gnome-control-center
    gnome-usage
    
    # KDE/Qt packages
    kdePackages.syntax-highlighting
    kdePackages.kirigami          # Kirigami framework
    libsForQt5.qtgraphicaleffects  # Qt5 GraphicalEffects module
    qt6.qt5compat                  # Qt6 Qt5 compatibility layer
    
    # Qt5 packages
    libsForQt5.qtquickcontrols2
    libsForQt5.qtquickcontrols
    
    # Qt6 packages (correct names)
    qt6.qtdeclarative              # Includes QtQuick
    qt6.qtquick3d
    qt6.qtpositioning              # QtPositioning for geolocation/weather
    
    # Fonts
    material-symbols
    rubik
    nerd-fonts.space-mono
    
    # Theme engines
    libsForQt5.qtstyleplugin-kvantum
    kdePackages.qtstyleplugin-kvantum
    
    # Other tools
    better-control
  ];

  # Use patched quickshell config from dots-hyprland flake input
  # Apply our bindd-aware get_keybinds.py patch
  home.file.".config/quickshell/default".source = pkgs.runCommand "quickshell-config-patched" {} ''
    cp -r ${inputs.dots-hyprland}/dots/.config/quickshell/ii $out
    chmod -R u+w $out

    # Replace get_keybinds.py with our patched version that handles bindd
    cp ${../scripts/quickshell/hyprland/get_keybinds.py} $out/scripts/hyprland/get_keybinds.py
    chmod +x $out/scripts/hyprland/get_keybinds.py
  '';
}