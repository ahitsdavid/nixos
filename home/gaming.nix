# home/gaming.nix
{ config, pkgs, inputs, ... }:
let
  # Optimized Pokerogue wrapper that forces X11 mode
  # Forces X11 platform to fix ANGLE EGL initialization issues
  pokerogue-optimized = pkgs.writeShellScriptBin "pokerogue-app" ''
    export GDK_BACKEND=x11
    exec ${inputs.pokerogue-app.packages.x86_64-linux.pokerogue-app}/bin/pokerogue \
      --ozone-platform=x11 \
      --enable-features=VaapiVideoDecoder \
      --enable-gpu-rasterization \
      --enable-accelerated-2d-canvas \
      "$@"
  '';
in
{
  home.packages = with pkgs; [
    pokerogue-optimized

    # Minecraft
    prismlauncher
    jdk21
  ];

  programs.mangohud = {
    enable = false;
    enableSessionWide = true;
  };
}