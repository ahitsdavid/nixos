{ config, pkgs, ... }: {
  programs.chromium = {
    enable = true;
    commandLineArgs = [
      "--no-default-browser-check"
      "--disable-default-apps"
      "--no-first-run"
    ];
  };

  # Set policy files to disable default browser prompts
  home.file.".config/chromium/policies/managed/no_default_browser_check.json" = {
    text = ''
      {
        "DefaultBrowserSettingEnabled": false,
        "BrowserAddPersonEnabled": false,
        "DefaultBrowserPromptEnabled": false
      }
    '';
  };
}