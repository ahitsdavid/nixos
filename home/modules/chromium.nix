{ config, pkgs, ... }: 
let
  chromium-wrapped = pkgs.chromium.override {
    commandLineArgs = [
      "--no-default-browser-check"
      "--disable-default-apps"
    ];
  };
in {
  # Chromium package with no default browser check
  home.packages = with pkgs; [
    chromium-wrapped
  ];

  # Set policy files to disable default browser prompts
  home.file.".config/chromium/policies/managed/no_default_browser_check.json" = {
    text = ''
      {
        "DefaultBrowserSettingEnabled": false,
        "BrowserAddPersonEnabled": false
      }
    '';
  };
}