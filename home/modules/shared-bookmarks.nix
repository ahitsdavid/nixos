# home/modules/shared-bookmarks.nix
# Shared bookmarks configuration for Firefox and Zen Browser
{ ... }:
{
  # Define your bookmarks here - they will be shared across all browsers
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
          # Add more work bookmarks here
        ];
      }
      {
        name = "Development";
        bookmarks = [
          # Add development-related bookmarks
          # {
          #   name = "GitHub";
          #   url = "https://github.com";
          # }
        ];
      }
      {
        name = "Personal";
        bookmarks = [
          {
            name = "Vaultwarden";
            url = "https://sharky-nas.tailb3f624.ts.net:18443";
          }
          {
            name = "Unraid";
            url = "https://sharky-nas.tailb3f624.ts.net:18043";
          }
          {
            name = "qBittorrent";
            url = "https://sharky-nas.tailb3f624.ts.net:18080";
          }
          {
            name = "Immich";
            url = "https://sharky-nas.tailb3f624.ts.net:18081";
          }
          {
            name = "NextCloud";
            url = "https://sharky-nas.tailb3f624.ts.net:18082";
          }
          {
            name = "Radarr";
            url = "http://192.168.1.29:7878";
          }
          {
            name = "Sonarr";
            url = "http://192.168.1.29:8989";
          }
          {
            name = "Prowlarr";
            url = "http://192.168.1.29:9696";
          }
          {
            name = "Plex";
            url = "https://sharky-nas.tailb3f624.ts.net:32443";
          }
        ];
      }
    ];
  };
}
