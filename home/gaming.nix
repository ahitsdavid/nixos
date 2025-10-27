# home/gaming.nix
{ config, pkgs, inputs, ... }:
let
  # Optimized Pokerogue wrapper that fixes EGL/hardware acceleration
  # Forces native OpenGL and uses X11 for better compatibility
  pokerogue-optimized = pkgs.writeShellScriptBin "pokerogue-app" ''
    exec ${inputs.pokerogue-app.packages.x86_64-linux.pokerogue-app}/bin/pokerogue \
      --use-gl=desktop \
      --enable-features=VaapiVideoDecoder,UseOzonePlatform \
      --ozone-platform=x11 \
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