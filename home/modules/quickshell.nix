{ config, lib, pkgs, ... }:

{
  # Use the official Home Manager QuickShell module
  programs.quickshell = {
    enable = true;
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
    ]}"
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
      "${pkgs.kdePackages.syntax-highlighting}/lib/qt-6/qml"
    ];
  };

  # Also add to shell profile for immediate availability
  programs.bash.sessionVariables = {
    QML2_IMPORT_PATH = lib.concatStringsSep ":" [
      "${pkgs.libsForQt5.qtgraphicaleffects}/${pkgs.libsForQt5.qtbase.qtQmlPrefix}"
      "${pkgs.qt6.qt5compat}/${pkgs.qt6.qtbase.qtQmlPrefix}"
      "${pkgs.kdePackages.syntax-highlighting}/lib/qt-6/qml"
    ];
  };

  # And for zsh if you use it
  programs.zsh.sessionVariables = {
    QML2_IMPORT_PATH = lib.concatStringsSep ":" [
      "${pkgs.libsForQt5.qtgraphicaleffects}/${pkgs.libsForQt5.qtbase.qtQmlPrefix}"
      "${pkgs.qt6.qt5compat}/${pkgs.qt6.qtbase.qtQmlPrefix}"
      "${pkgs.kdePackages.syntax-highlighting}/lib/qt-6/qml"
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

  # Automatically clone/pull dotfiles from GitHub
  home.activation.cloneDotfiles = lib.hm.dag.entryAfter ["writeBoundary"] ''
    DOTFILES_DIR="${config.home.homeDirectory}/dotfiles"
    DOTFILES_REPO="https://github.com/ahitsdavid/dotfiles"

    # Add openssh to PATH for git operations
    export PATH="${pkgs.openssh}/bin:$PATH"

    # Check if network is available before attempting git operations
    if ${pkgs.iputils}/bin/ping -c 1 -W 2 github.com >/dev/null 2>&1; then
      if [ ! -d "$DOTFILES_DIR" ]; then
        $DRY_RUN_CMD ${pkgs.git}/bin/git clone "$DOTFILES_REPO" "$DOTFILES_DIR"
        echo "Cloned dotfiles repository to $DOTFILES_DIR"
      else
        $DRY_RUN_CMD ${pkgs.git}/bin/git -C "$DOTFILES_DIR" pull
        echo "Updated dotfiles repository at $DOTFILES_DIR"
      fi
    else
      echo "Network not available, skipping dotfiles clone/pull"
    fi
  '';

  # Create the config symlink to your dotfiles in home directory
  # Use config.lib.file.mkOutOfStoreSymlink to properly reference home directory
  home.file.".config/quickshell".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/.config/quickshell";
}