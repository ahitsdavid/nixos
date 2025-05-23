# env.nix
{ config, lib, pkgs, ... }:

{
  wayland.windowManager.hyprland = {
    settings = {
      env = [
        # Input method
        "QT_IM_MODULE, fcitx"
        "XMODIFIERS, @im=fcitx"
        # "GTK_IM_MODULE, wayland"   # Crashes electron apps in xwayland
        # "GTK_IM_MODULE, fcitx"     # My Gtk apps no longer require this to work with fcitx5 hmm
        "SDL_IM_MODULE, fcitx"
        "GLFW_IM_MODULE, ibus"
        "INPUT_METHOD, fcitx"
        
        # Themes
        "QT_QPA_PLATFORM, wayland"
        "QT_QPA_PLATFORMTHEME, qt6ct"
        # "QT_STYLE_OVERRIDE, kvantum"
        # "WLR_NO_HARDWARE_CURSORS, 1"
        
        # Screen tearing
        # "WLR_DRM_NO_ATOMIC, 1"
        
      ];
    };
  };

  # Optional: Install related packages
  #home.packages = with pkgs; [
  #  fcitx5
  #  fcitx5-with-addons
  #  qt6ct
  #  # libsForQt5.qtstyleplugin-kvantum  # Uncomment if you need Kvantum
  #];
  
  # Optional: Configure input method properly in Home Manager
  #i18n.inputMethod = {
  #  enabled = "fcitx5";
  #  fcitx5.addons = with pkgs; [
  #    # fcitx5-chinese-addons
  #    # Add other fcitx5 addons you need
  #  ];
  #};
}
