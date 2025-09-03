{ config, pkgs, ... }: {
  # Chromium package with wrapper to disable default browser check
  home.packages = with pkgs; [
    (chromium.override {
      commandLineArgs = [
        "--no-default-browser-check"
        "--disable-default-apps"
      ];
    })
  ];

  # Also set the policy file as backup
  home.file.".config/chromium/policies/managed/no_default_browser_check.json" = {
    text = ''
      {
        "DefaultBrowserSettingEnabled": false,
        "BrowserAddPersonEnabled": false
      }
    '';
  };
}