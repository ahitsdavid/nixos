{pkgs, lib, username, ...}: {
  # Login Environment
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
    theme = "catppuccin-mocha";
    package = pkgs.kdePackages.sddm;
  };

  environment.systemPackages = [
    pkgs.catppuccin-sddm
  ];

}
