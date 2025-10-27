# home/gaming.nix
{ config, pkgs, inputs, ... }:
let
  # Optimized Pokerogue wrapper with performance flags
  pokerogue-optimized = pkgs.writeShellScriptBin "pokerogue-app" ''
    exec ${inputs.pokerogue-app.packages.x86_64-linux.pokerogue-app}/bin/pokerogue \
      --enable-features=VaapiVideoDecoder,VaapiVideoEncoder,Vulkan \
      --enable-gpu-rasterization \
      --enable-zero-copy \
      --ignore-gpu-blocklist \
      --disable-software-rasterizer \
      --enable-accelerated-2d-canvas \
      --num-raster-threads=4 \
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