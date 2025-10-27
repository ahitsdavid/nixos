# home/gaming.nix
{ config, pkgs, inputs, ... }:
let
  # Optimized Pokerogue wrapper with proper EGL environment
  # Sets up Mesa/Intel drivers and disables Wayland to fix ANGLE initialization
  pokerogue-optimized = pkgs.writeShellScriptBin "pokerogue-app" ''
    export LIBGL_ALWAYS_SOFTWARE=0
    export __EGL_VENDOR_LIBRARY_FILENAMES=${pkgs.mesa.drivers}/share/glvnd/egl_vendor.d/50_mesa.json
    export MESA_LOADER_DRIVER_OVERRIDE=iris
    exec ${inputs.pokerogue-app.packages.x86_64-linux.pokerogue-app}/bin/pokerogue \
      --disable-features=UseOzonePlatform \
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