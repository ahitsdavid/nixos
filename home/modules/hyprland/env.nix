# env.nix - Common environment variables for all hosts
{ config, lib, pkgs, ... }:

{
  wayland.windowManager.hyprland.settings.env = [
    # Wayland
    "NIXOS_OZONE_WL,1"
    "NIXPKGS_ALLOW_UNFREE,1"
    "XDG_SESSION_TYPE,wayland"
    "XDG_SESSION_DESKTOP,Hyprland"
    "XDG_CURRENT_DESKTOP,Hyprland"
    "GDK_BACKEND,wayland,x11"
    "CLUTTER_BACKEND,wayland"
    "MOZ_ENABLE_WAYLAND,1"

    # Qt
    "QT_QPA_PLATFORM,wayland;xcb"
    "QT_WAYLAND_DISABLE_WINDOWDECORATION,1"
    "QT_AUTO_SCREEN_SCALE_FACTOR,1"
    "QT_QPA_PLATFORMTHEME,gtk3"

    # SDL
    "SDL_VIDEODRIVER,x11"

    # Scaling
    "GDK_SCALE,1"
    "QT_SCALE_FACTOR,1"

    # Input method (fcitx)
    "QT_IM_MODULE,fcitx"
    "XMODIFIERS,@im=fcitx"
    "SDL_IM_MODULE,fcitx"
    "GLFW_IM_MODULE,ibus"
    "INPUT_METHOD,fcitx"

    # Cursor
    "WLR_NO_HARDWARE_CURSORS,1"
    "HYPRCURSOR_THEME,rose-pine-hyprcursor"
    "HYPRCURSOR_SIZE,40"
    "XCURSOR_THEME,rose-pine-hyprcursor"
    "XCURSOR_SIZE,40"

    # Defaults
    "EDITOR,nvim"
    "BROWSER,firefox"
    "TERMINAL,kitty"
    "XDG_TERMINAL_EMULATOR,kitty"

    # Quickshell
    "QML2_IMPORT_PATH,qmlImportPath"

    # QEMU
    "LIBVIRT_DEFAULT_URI,qemu:///system"

    # Electron
    "ELECTRON_OZONE_PLATFORM_HINT,wayland"
  ];
}
