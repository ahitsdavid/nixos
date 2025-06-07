# home/modules/firefox/default.nix
# Firefox config
{ config, pkgs, ... }: {

  programs.firefox = {
    enable = true;
    package = pkgs.firefox;
    profiles = {
      default = {
      id = 0;
        isDefault = true;
        extensions.packages = with pkgs.nur.repos.rycee.firefox-addons; [
          ublock-origin
          bitwarden
          buster-captcha-solver
          translate-web-pages
          return-youtube-dislikes
          sponsorblock
          catppuccin-web-file-icons
          catppuccin-mocha-mauve
          windscribe
        ];
        settings = {
          "browser.startup.homepage" = "https://www.google.com";
          "browser.startup.page" = 1;
          "browser.shell.checkDefaultBrowser" = false;
        };
        bookmarks = {
          force = true;
          settings = [
            {
              name = "Work Bookmarks";
              bookmarks = [
                {
                  name = "Web Git";
                  url = "https://web.git.mil";
                }
              ];
            }
          ];
        };
      };
    };
  };
}
