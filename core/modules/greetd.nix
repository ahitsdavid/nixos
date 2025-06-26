{pkgs, lib, username, ...}: {
  # Login Environment
  services.greetd = {
    enable = true;
    vt = 3;
    settings = {
      default_session = {
        user = username;
        command = lib.concatStringsSep " " [
          "${pkgs.greetd.tuigreet}/bin/tuigreet"
          "--time"
          "--cmd Hyprland"
          # Catppuccin Mocha color scheme
          "--container-padding 2"
          "--prompt-padding 1"
          "--asterisks"
          "--asterisks-char ●"
          "--window-padding 2"
          "--greeting 'Welcome to NixOS'"
        ];
      };
    };
  };
}