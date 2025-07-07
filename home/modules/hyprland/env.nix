# env.nix
{ config, lib, pkgs, ... }:

{
  wayland.windowManager.hyprland = {
    settings = {
      env = [
        "NIXOS_OZONE_WL, 1"
        "NIXPKGS_ALLOW_UNFREE, 1"
        "XDG_SESSION_TYPE, wayland"
        "XDG_SESSION_DESKTOP, Hyprland"
        "XDG_CURRENT_DESKTOP, Hyprland"
        "GDK_BACKEND, wayland, x11"
        "CLUTTER_BACKEND, wayland"
        "QT_QPA_PLATFORM=wayland;xcb"
        "QT_WAYLAND_DISABLE_WINDOWDECORATION, 1"
        "QT_AUTO_SCREEN_SCALE_FACTOR, 1"
        "SDL_VIDEODRIVER, x11"
        "MOZ_ENABLE_WAYLAND, 1"
        "GDK_SCALE,1"
        "QT_SCALE_FACTOR,1"

        # Input method
        "QT_IM_MODULE, fcitx"
        "XMODIFIERS, @im=fcitx"
        # "GTK_IM_MODULE, wayland"   # Crashes electron apps in xwayland
        # "GTK_IM_MODULE, fcitx"     # My Gtk apps no longer require this to work with fcitx5 hmm
        "SDL_IM_MODULE, fcitx"
        "GLFW_IM_MODULE, ibus"
        "INPUT_METHOD, fcitx"
        
        # Themes - let Stylix handle GTK theme names
        "QT_QPA_PLATFORM, wayland"
        "QT_QPA_PLATFORMTHEME, gtk3"  # Override qt5ct to prevent kvantum style loading
        "QT_STYLE_OVERRIDE, "  # Clear any kvantum style override
        "WLR_NO_HARDWARE_CURSORS, 1"
        
        # HYPRCURSOR
        "HYPRCURSOR_THEME, rose-pine-hyprcursor"
        "HYPRCURSOR_SIZE, 40"
        
        # XCURSOR (for X11/XWayland apps like Zen browser)
        "XCURSOR_THEME, rose-pine-hyprcursor"
        "XCURSOR_SIZE, 40"

        # DEFAULTS
        "EDITOR, nvim"
        "BROWSER, firefox"
        "TERMINAL, kitty"
        "XDG_TERMINAL_EMULATOR,kitty"

        # QUICKSHELL
        "QML2_IMPORT_PATH, qmlImportPath"

        # QEMU
        "LIBVIRT_DEFAULT_URI, qemu:///system"

        # VSCODE
        "ELECTRON_OZONE_PLATFORM_HINT, wayland"

        # Screen tearing
        # "WLR_DRM_NO_ATOMIC, 1"
        
      ];
    };
  };
}
