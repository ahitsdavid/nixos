# window-rules.nix
{ config, lib, pkgs, ... }:

{
  wayland.windowManager.hyprland = {
    settings = {
      # Window rules v2 (opacity rules moved here for Hyprland 0.52.0+ compatibility)
      windowrulev2 = [
        # VSCode - blur and opacity
        "opacity 0.8 0.8 1, class:^(code)$"
        "opacity 0.8 0.8 1, class:^([Cc]ode)$"
        "opacity 0.8 0.8 1, class:^(code-url-handler)$"
        "opacity 0.8 0.8 1, class:^(dev.zed.Zed)$"
        "opacity 0.8 0.8 1, class:^(zed)$"

        # Uncomment to apply global transparency to all windows:
        # "opacity 0.89 override 0.89 override, class:.*"

        # Disable blur for XWayland windows (or context menus with shadow would look weird)
        "noblur, xwayland:1"

        # Floating
        "float, class:^(blueberry\\.py)$"
        "float, class:^(steam)$"
        "float, class:^(guifetch)$"   # FlafyDev/guifetch
        "float, class:^(pavucontrol)$"
        "size 45%, class:^(pavucontrol)$"
        "center, class:^(pavucontrol)$"
        "float, class:^(org.pulseaudio.pavucontrol)$"
        "size 45%, class:^(org.pulseaudio.pavucontrol)$"
        "center, class:^(org.pulseaudio.pavucontrol)$"
        "float, class:^(nm-connection-editor)$"
        "size 45%, class:^(nm-connection-editor)$"
        "center, class:^(nm-connection-editor)$"

        # Quickshell Settings
        "float, title:^(Quickshell Settings)$"
        "size 70% 80%, title:^(Quickshell Settings)$"
        "center, title:^(Quickshell Settings)$"

        # Tiling
        "tile, class:^dev\\.warp\\.Warp$"

        # Picture-in-Picture
        "float, title:^([Pp]icture[-\\s]?[Ii]n[-\\s]?[Pp]icture)(.*)$"
        "keepaspectratio, title:^([Pp]icture[-\\s]?[Ii]n[-\\s]?[Pp]icture)(.*)$"
        "move 73% 72%, title:^([Pp]icture[-\\s]?[Ii]n[-\\s]?[Pp]icture)(.*)$"
        "size 25%, title:^([Pp]icture[-\\s]?[Ii]n[-\\s]?[Pp]icture)(.*)$"
        "float, title:^([Pp]icture[-\\s]?[Ii]n[-\\s]?[Pp]icture)(.*)$"
        "pin, title:^([Pp]icture[-\\s]?[Ii]n[-\\s]?[Pp]icture)(.*)$"

        # Dialog windows – float+center these windows.
        "center, title:^(Open File)(.*)$"
        "center, title:^(Select a File)(.*)$"
        "center, title:^(Choose wallpaper)(.*)$"
        "center, title:^(Open Folder)(.*)$"
        "center, title:^(Save As)(.*)$"
        "center, title:^(Library)(.*)$"
        "center, title:^(File Upload)(.*)$"
        "float, title:^(Open File)(.*)$"
        "float, title:^(Select a File)(.*)$"
        "float, title:^(Choose wallpaper)(.*)$"
        "float, title:^(Open Folder)(.*)$"
        "float, title:^(Save As)(.*)$"
        "float, title:^(Library)(.*)$"
        "float, title:^(File Upload)(.*)$"

        # --- Tearing ---
        "immediate, title:.*\\.exe"
        "immediate, class:^(steam_app)"

        # No shadow for tiled windows (matches windows that are not floating).
        "noshadow, floating:0"
      ];

      # Workspace rules
      workspace = "special:special, gapsout:30";

      # Layer rules - Updated for Hyprland 0.53.0+
      # New syntax requires explicit "on" values and "match:namespace" selectors
      layerrule = [
        "xray on, match:namespace .*"
        "no_anim on, match:namespace walker"
        "no_anim on, match:namespace selection"
        "no_anim on, match:namespace overview"
        "no_anim on, match:namespace anyrun"
        "no_anim on, match:namespace indicator.*"
        "no_anim on, match:namespace osk"
        "no_anim on, match:namespace hyprpicker"
        "no_anim on, match:namespace noanim"
        "blur on, match:namespace gtk-layer-shell"
        "ignore_alpha 0, match:namespace gtk-layer-shell"
        "blur on, match:namespace launcher"
        "ignore_alpha 0.5, match:namespace launcher"
        "blur on, match:namespace notifications"
        "ignore_alpha 0.69, match:namespace notifications"
        "blur on, match:namespace logout_dialog"
        "animation slide left, match:namespace sideleft.*"
        "animation slide right, match:namespace sideright.*"
        "blur on, match:namespace session[0-9]*"
        "blur on, match:namespace bar[0-9]*"
        "ignore_alpha 0.6, match:namespace bar[0-9]*"
        "blur on, match:namespace barcorner.*"
        "ignore_alpha 0.6, match:namespace barcorner.*"
        "blur on, match:namespace dock[0-9]*"
        "ignore_alpha 0.6, match:namespace dock[0-9]*"
        "blur on, match:namespace indicator.*"
        "ignore_alpha 0.6, match:namespace indicator.*"
        "blur on, match:namespace overview[0-9]*"
        "ignore_alpha 0.6, match:namespace overview[0-9]*"
        "blur on, match:namespace cheatsheet[0-9]*"
        "ignore_alpha 0.6, match:namespace cheatsheet[0-9]*"
        "blur on, match:namespace sideright[0-9]*"
        "ignore_alpha 0.6, match:namespace sideright[0-9]*"
        "blur on, match:namespace sideleft[0-9]*"
        "ignore_alpha 0.6, match:namespace sideleft[0-9]*"
        "blur on, match:namespace osk[0-9]*"
        "ignore_alpha 0.6, match:namespace osk[0-9]*"

        # Quickshell-specific namespace rules
        "blur_popups on, match:namespace quickshell:.*"
        "blur on, match:namespace quickshell:.*"
        "ignore_alpha 0.79, match:namespace quickshell:.*"
        "animation slide, match:namespace quickshell:bar"
        "animation fade, match:namespace quickshell:screenCorners"
        "animation slide right, match:namespace quickshell:sidebarRight"
        "animation slide left, match:namespace quickshell:sidebarLeft"
        "animation slide bottom, match:namespace quickshell:osk"
        "animation slide bottom, match:namespace quickshell:dock"
        "blur on, match:namespace quickshell:session"
        "no_anim on, match:namespace quickshell:session"
        "ignore_alpha 0, match:namespace quickshell:session"
        "animation fade, match:namespace quickshell:notificationPopup"
        "blur on, match:namespace quickshell:backgroundWidgets"
        "ignore_alpha 0.05, match:namespace quickshell:backgroundWidgets"
        "no_anim on, match:namespace quickshell:overview"  # Launchers need to be FAST
      ];
    };
  };
}
