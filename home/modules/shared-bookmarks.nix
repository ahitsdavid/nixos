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
          # Add personal bookmarks
          # {
          #   name = "Gmail";
          #   url = "https://mail.google.com";
          # }
        ];
      }
    ];
  };
}
