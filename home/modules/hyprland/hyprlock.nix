{username, lib, ...}: {
  programs.hyprlock = {
    enable = true;
    settings = {
      general = {
        disable_loading_bar = true;
        grace = 10;
        hide_cursor = true;
        no_fade_in = true;
      };
      background = lib.mkForce [
        {
          path = "/home/${username}/Pictures/Wallpapers/yosemite.png";
          blur_passes = 3;
          blur_size = 8;
        }
      ];
    };
  };
}
