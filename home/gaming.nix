# home/gaming.nix
{ config, pkgs, inputs, ... }:
let
  # Optimized Pokerogue wrapper that forces X11 mode
  # Unsets Wayland to fix ANGLE EGL initialization issues
  pokerogue-optimized = pkgs.writeShellScriptBin "pokerogue-app" ''
    unset WAYLAND_DISPLAY
    export GDK_BACKEND=x11
    exec ${inputs.pokerogue-app.packages.x86_64-linux.pokerogue-app}/bin/pokerogue \
      --enable-features=VaapiVideoDecoder \
      --enable-gpu-rasterization \
      --enable-accelerated-2d-canvas \
      "$@"
  '';
in
{
  home.packages = with pkgs; [
    pokerogue-optimized
  ];

  programs.mangohud = {
    enable = false;
    enableSessionWide = true;
  };
}