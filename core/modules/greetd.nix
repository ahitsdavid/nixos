{pkgs, lib, username, ...}: {
  # Login Environment
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        user = username;
        command = lib.concatStringsSep " " [
          "${pkgs.tuigreet}/bin/tuigreet"
          "--time"
          "--cmd Hyprland"
          "--container-padding 2"
          "--prompt-padding 1"
          "--asterisks"
          "--asterisks-char ●"
          "--window-padding 2"
          "--greeting 'Welcome to NixOS'"
          "--remember"
          "--remember-user-session"
          "--power-shutdown 'systemctl poweroff'"
          "--power-reboot 'systemctl reboot'"
          #"--theme 'border=magenta;text=text;prompt=sky;time=overlay1;action=blue;button=surface0;container=base;input=surface0'"
        ];
      };
    };
    vt = 1;
  };

  # Additional systemd configuration to prevent console messages from interfering
  systemd.services.greetd = {
    unitConfig = {
      After = "systemd-user-sessions.service plymouth-quit-wait.service getty@tty1.service";
    };
    serviceConfig = {
      # Clear the console before starting greetd
      ExecStartPre = "${pkgs.coreutils}/bin/clear";
      # Ensure greetd has exclusive access to the console
      TTYPath = "/dev/tty1";
      TTYReset = "yes";
      TTYVHangup = "yes";
      TTYVTDisallocate = "yes";
      # Prevent other processes from writing to the console
      StandardInput = "tty-force";
      StandardOutput = "tty";
      StandardError = "tty";
    };
  };

  # Disable getty on tty1 since greetd will use it
  systemd.services."getty@tty1".enable = false;
  systemd.services."autovt@tty1".enable = false;
}