{ config, pkgs, ... }: {
  # Chromium package
  home.packages = with pkgs; [
    chromium
  ];

  # Configure Chromium to not ask about default browser
  home.file.".config/chromium/Default/Preferences" = {
    text = ''
      {
        "browser": {
          "check_default_browser": false,
          "default_browser_setting_enabled": false
        }
      }
    '';
  };
}