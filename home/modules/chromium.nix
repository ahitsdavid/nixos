{ config, pkgs, ... }: 
let
  chromium-no-default = pkgs.writeShellScriptBin "chromium" ''
    exec ${pkgs.chromium}/bin/chromium --no-default-browser-check --disable-default-apps "$@"
  '';
in {
  # Chromium package with wrapper script
  home.packages = with pkgs; [
    chromium-no-default
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