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
          "--container-padding 2"
          "--prompt-padding 1"
          "--asterisks"
          "--asterisks-char ●"
          "--window-padding 2"
          "--greeting 'Welcome to NixOS'"
          #"--theme 'border=magenta;text=text;prompt=sky;time=overlay1;action=blue;button=surface0;container=base;input=surface0'"
        ];
      };
    };
  };
}