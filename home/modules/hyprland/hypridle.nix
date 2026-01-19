{ ... }:

{
  services = {
    hypridle = {
      enable = true;
      settings = {
        general = {
          lock_cmd = "hyprctl dispatch global quickshell:lock";
          before_sleep_cmd = "loginctl lock-session";
          after_sleep_cmd = "hyprctl dispatch global quickshell:lockFocus";
          ignore_dbus_inhibit = false;
          };
        listener = [
          {
            timeout = 900;
            on-timeout = "loginctl lock-session";
          }
          {
            timeout = 1200;
            on-timeout = "hyprctl dispatch dpms off";
            on-resume = "hyprctl dispatch dpms on";
          }
          {
            timeout = 1500;
            on-timeout = "systemctl suspend || loginctl suspend";
          }
        ];
      };
    };
  };
}
