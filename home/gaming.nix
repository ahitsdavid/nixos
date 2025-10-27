# home/gaming.nix
{ config, pkgs, inputs, ... }:
let
  # Conservative Pokerogue wrapper with safe performance flags
  # Keeps software rendering fallback, doesn't ignore GPU blocklist
  pokerogue-optimized = pkgs.writeShellScriptBin "pokerogue-app" ''
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