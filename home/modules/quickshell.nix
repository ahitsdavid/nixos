{ config, lib, pkgs, ... }:

{
  # Use the official Home Manager QuickShell module
  programs.quickshell = {
    enable = true;
    # Remove package line to use default, or specify if needed
    # package = pkgs.quickshell; # if available in nixpkgs
    
    # Set the config directory - commented out for now
    # activeConfig = "default";
    # configs = {
    #   default = "${config.home.homeDirectory}/dotfiles/.config/quickshell";
    # };
    
    # Enable systemd service
    systemd = {
      enable = true;
    };
  };

  # Extend the official systemd service to add environment variables
  systemd.user.services.quickshell.Service.Environment = [
    "QML2_IMPORT_PATH=${lib.concatStringsSep ":" [
      "${pkgs.libsForQt5.qtgraphicaleffects}/${pkgs.libsForQt5.qtbase.qtQmlPrefix}"
      "${pkgs.qt6.qt5compat}/${pkgs.qt6.qtbase.qtQmlPrefix}"
      "${pkgs.kdePackages.syntax-highlighting}/lib/qt-6/qml"
      # Removed invalid kvantum QML paths - kvantum provides style plugins, not QML modules
    ]}"
  ];

  # Add QML import paths as session variables
  home.sessionVariables = {
    QML2_IMPORT_PATH = lib.concatStringsSep ":" [
      "${pkgs.libsForQt5.qtgraphicaleffects}/${pkgs.libsForQt5.qtbase.qtQmlPrefix}"
      "${pkgs.qt6.qt5compat}/${pkgs.qt6.qtbase.qtQmlPrefix}"
      "${pkgs.kdePackages.syntax-highlighting}/lib/qt-6/qml"
      # Removed invalid kvantum QML paths - kvantum provides style plugins, not QML modules
    ];
  };

  # Also add to shell profile for immediate availability
  programs.bash.sessionVariables = {
    QML2_IMPORT_PATH = lib.concatStringsSep ":" [
      "${pkgs.libsForQt5.qtgraphicaleffects}/${pkgs.libsForQt5.qtbase.qtQmlPrefix}"
      "${pkgs.qt6.qt5compat}/${pkgs.qt6.qtbase.qtQmlPrefix}"
      "${pkgs.kdePackages.syntax-highlighting}/lib/qt-6/qml"
      # Removed invalid kvantum QML paths - kvantum provides style plugins, not QML modules
    ];
  };

  # And for zsh if you use it
  programs.zsh.sessionVariables = {
    QML2_IMPORT_PATH = lib.concatStringsSep ":" [
      "${pkgs.libsForQt5.qtgraphicaleffects}/${pkgs.libsForQt5.qtbase.qtQmlPrefix}"
      "${pkgs.qt6.qt5compat}/${pkgs.qt6.qtbase.qtQmlPrefix}"
      "${pkgs.kdePackages.syntax-highlighting}/lib/qt-6/qml"
      # Removed invalid kvantum QML paths - kvantum provides style plugins, not QML modules
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
    libsForQt5.qtgraphicaleffects  # Qt5 GraphicalEffects module
    qt6.qt5compat                  # Qt6 Qt5 compatibility layer
    
    # Qt5 packages
    libsForQt5.qtquickcontrols2
    libsForQt5.qtquickcontrols
    
    # Qt6 packages (correct names)
    qt6.qtdeclarative              # Includes QtQuick
    qt6.qtquick3d
    
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

  # Create the config symlink to your dotfiles in home directory
  # Use config.lib.file.mkOutOfStoreSymlink to properly reference home directory
  home.file.".config/quickshell".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/.config/quickshell";
}