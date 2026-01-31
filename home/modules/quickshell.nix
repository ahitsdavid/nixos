{ config, lib, pkgs, inputs, ... }:

{
  # Persist GNOME dark mode setting - required for matugen to generate dark colors
  # The end-4 quickshell uses switchwall.sh which checks this gsettings value
  # to determine whether to generate dark or light Material You colors
  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = lib.mkForce "prefer-dark";
      gtk-theme = lib.mkForce "adw-gtk3-dark";
    };
  };

  # Use the official QuickShell from flake (has polkit support)
  programs.quickshell = {
    enable = true;
    package = inputs.quickshell.packages.${pkgs.stdenv.hostPlatform.system}.default;
    systemd = {
      enable = true;
    };
  };

  # Extend the official systemd service to add environment variables
  systemd.user.services.quickshell.Service.Environment = [
    "QML2_IMPORT_PATH=${lib.concatStringsSep ":" [
      "${pkgs.kdePackages.qt5compat}/${pkgs.kdePackages.qtbase.qtQmlPrefix}"
      "${pkgs.kdePackages.qtpositioning}/${pkgs.kdePackages.qtbase.qtQmlPrefix}"
      "${pkgs.kdePackages.qtmultimedia}/${pkgs.kdePackages.qtbase.qtQmlPrefix}"
      "${pkgs.kdePackages.syntax-highlighting}/lib/qt-6/qml"
      "${pkgs.kdePackages.kirigami.unwrapped}/lib/qt-6/qml"
    ]}"
    "QML_IMPORT_PATH=${lib.concatStringsSep ":" [
      "${pkgs.kdePackages.qt5compat}/${pkgs.kdePackages.qtbase.qtQmlPrefix}"
      "${pkgs.kdePackages.qtpositioning}/${pkgs.kdePackages.qtbase.qtQmlPrefix}"
      "${pkgs.kdePackages.qtmultimedia}/${pkgs.kdePackages.qtbase.qtQmlPrefix}"
      "${pkgs.kdePackages.syntax-highlighting}/lib/qt-6/qml"
      "${pkgs.kdePackages.kirigami.unwrapped}/lib/qt-6/qml"
    ]}"
    # NVIDIA Wayland environment variables for proper EGL initialization
    "GBM_BACKEND=nvidia-drm"
    "__GLX_VENDOR_LIBRARY_NAME=nvidia"
    "LIBVA_DRIVER_NAME=nvidia"
    # Virtual environment for Python scripts
    "ILLOGICAL_IMPULSE_VIRTUAL_ENV=${config.home.homeDirectory}/.local/state/quickshell/.venv"
  ];

  # Add session variables
  home.sessionVariables = {
    QML2_IMPORT_PATH = lib.concatStringsSep ":" [
      "${pkgs.kdePackages.qt5compat}/${pkgs.kdePackages.qtbase.qtQmlPrefix}"
      "${pkgs.kdePackages.qtpositioning}/${pkgs.kdePackages.qtbase.qtQmlPrefix}"
      "${pkgs.kdePackages.qtmultimedia}/${pkgs.kdePackages.qtbase.qtQmlPrefix}"
      "${pkgs.kdePackages.syntax-highlighting}/lib/qt-6/qml"
      "${pkgs.kdePackages.kirigami.unwrapped}/lib/qt-6/qml"
    ];
    QML_IMPORT_PATH = lib.concatStringsSep ":" [
      "${pkgs.kdePackages.qt5compat}/${pkgs.kdePackages.qtbase.qtQmlPrefix}"
      "${pkgs.kdePackages.qtpositioning}/${pkgs.kdePackages.qtbase.qtQmlPrefix}"
      "${pkgs.kdePackages.qtmultimedia}/${pkgs.kdePackages.qtbase.qtQmlPrefix}"
      "${pkgs.kdePackages.syntax-highlighting}/lib/qt-6/qml"
      "${pkgs.kdePackages.kirigami.unwrapped}/lib/qt-6/qml"
    ];
    # Virtual environment for Python scripts used by quickshell
    ILLOGICAL_IMPULSE_VIRTUAL_ENV = "${config.home.homeDirectory}/.local/state/quickshell/.venv";
  };

  # Install additional packages that QuickShell needs
  home.packages = with pkgs; [
    # System tools
    glib  # Provides gsettings - needed by switchwall.sh to detect dark/light mode
    gammastep
    (geoclue2.override { withDemoAgent = true; })
    playerctl
    wireplumber
    pipewire
    libdbusmenu-gtk3
    ddcutil
    brightnessctl
    upower

    # Security/keyring
    libsecret      # Provides secret-tool for keyring storage
    gnome-keyring  # Credential storage
    kdePackages.polkit-kde-agent-1  # Polkit authentication agent

    # CLI utilities used by quickshell scripts
    jq
    ripgrep
    wl-clipboard
    cliphist
    bc
    imagemagick
    curl
    wget
    rsync

    # Color/theming
    matugen  # Material You color generation

    # Python with material-color-utilities for theming
    (python3.withPackages (ps: with ps; [
      pywayland
      pillow
      setuptools-scm
      material-color-utilities
    ]))

    # Hyprland utilities
    hyprsunset
    hypridle
    hyprpicker
    hyprlock
    hyprshot
    slurp
    swappy
    wf-recorder

    # Terminals (foot is used in quickshell config)
    foot
    kitty

    # Launchers/widgets
    fuzzel
    wlogout

    # Other utilities
    libqalculate  # Calculator
    translate-shell
    wtype
    ydotool
    mpv
    mpvpaper
    libcava  # Audio visualizer

    # GNOME tools
    gnome-control-center
    gnome-usage

    # KDE/Qt packages - use kdePackages for consistency
    kdePackages.kdialog
    kdePackages.qt5compat
    kdePackages.qtbase
    kdePackages.qtdeclarative
    kdePackages.qtimageformats
    kdePackages.qtmultimedia
    kdePackages.qtpositioning
    kdePackages.qtquicktimeline
    kdePackages.qtsensors
    kdePackages.qtsvg
    kdePackages.qttools
    kdePackages.qttranslations
    kdePackages.qtvirtualkeyboard
    kdePackages.qtwayland
    kdePackages.syntax-highlighting
    kdePackages.kirigami
    kdePackages.dolphin
    kdePackages.systemsettings
    kdePackages.bluedevil
    kdePackages.plasma-nm

    # Fonts
    material-symbols
    rubik
    nerd-fonts.space-mono
    nerd-fonts.jetbrains-mono
    nerd-fonts.ubuntu
    nerd-fonts.fantasque-sans-mono
    noto-fonts-color-emoji  # Don't use twemoji-color-font - broken fontconfig makes emoji primary font
    noto-fonts
    liberation_ttf

    # Theme engines and icons
    kdePackages.qtstyleplugin-kvantum
    adw-gtk3
    adwaita-icon-theme
    morewaita-icon-theme

    # Other tools
    better-control
    axel
  ];

  # Clean up old quickshell config before linking new one
  # This handles the transition from symlink to directory or vice versa
  home.activation.cleanQuickshellConfig = lib.hm.dag.entryBefore [ "linkGeneration" ] ''
    rm -rf "$HOME/.config/quickshell/default"
  '';

  # Use quickshell config from dots-hyprland flake input with custom overrides
  home.file.".config/quickshell/default".source = let
    baseConfig = "${inputs.dots-hyprland}/dots/.config/quickshell/ii";
    customScripts = ./hyprland/scripts;
    customOverrides = ./hyprland/quickshell-overrides;
  in pkgs.runCommand "quickshell-config-merged" {} ''
    # Copy base config
    cp -rL ${baseConfig} $out
    chmod -R u+w $out

    # Override with our custom keybind parsers
    cp ${customScripts}/get_keybinds.py $out/scripts/hyprland/get_keybinds.py
    chmod +x $out/scripts/hyprland/get_keybinds.py
    cp ${customScripts}/get_nvim_keybinds.py $out/scripts/hyprland/get_nvim_keybinds.py
    chmod +x $out/scripts/hyprland/get_nvim_keybinds.py
    cp ${customScripts}/get_terminal_keybinds.py $out/scripts/hyprland/get_terminal_keybinds.py
    chmod +x $out/scripts/hyprland/get_terminal_keybinds.py

    # Add custom services
    cp ${customOverrides}/services/NvimKeybinds.qml $out/services/NvimKeybinds.qml
    cp ${customOverrides}/services/TerminalKeybinds.qml $out/services/TerminalKeybinds.qml

    # Override cheatsheet with custom tabs
    cp ${customOverrides}/modules/ii/cheatsheet/Cheatsheet.qml $out/modules/ii/cheatsheet/Cheatsheet.qml
    cp ${customOverrides}/modules/ii/cheatsheet/CheatsheetNvim.qml $out/modules/ii/cheatsheet/CheatsheetNvim.qml
    cp ${customOverrides}/modules/ii/cheatsheet/CheatsheetTerminal.qml $out/modules/ii/cheatsheet/CheatsheetTerminal.qml

    # Override lock screen to include wallpaper background
    # (WlSessionLockSurface blocks other layers, so wallpaper must be rendered directly)
    cp ${customOverrides}/modules/ii/lock/LockSurface.qml $out/modules/ii/lock/LockSurface.qml
  '';

  # illogical-impulse config directory structure
  # The translations subdirectory is for AI-generated translations (optional)
  # Linking to built-in translations as fallback to prevent errors
  home.file.".config/illogical-impulse/translations".source = "${inputs.dots-hyprland}/dots/.config/quickshell/ii/translations";

  # Matugen config for color generation (required for quickshell theming)
  home.file.".config/matugen".source = "${inputs.dots-hyprland}/dots/.config/matugen";
}
