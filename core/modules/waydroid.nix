# Waydroid - Android container for Wayland
# Host-locked to Legion (uses Intel iGPU for proper GPU acceleration)
#
# After rebuild, run these imperative steps:
#   1. sudo waydroid init -s GAPPS -f   # (-s GAPPS for Google Play)
#   2. sudo systemctl start waydroid-container
#   3. waydroid session start
#   4. waydroid show-full-ui
#
# Useful commands:
#   waydroid app list
#   waydroid app install /path/to/app.apk
#   sudo waydroid shell
#   waydroid prop set persist.waydroid.width 1080
{pkgs, ...}: {
  virtualisation.waydroid.enable = true;

  environment.systemPackages = with pkgs; [
    wl-clipboard # For clipboard sharing between host and Android
  ];
}
