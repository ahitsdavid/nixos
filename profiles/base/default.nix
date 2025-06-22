# profiles/base/default.nix
{ inputs, username }:
{ config, pkgs, ... }: {
  imports = [
    (import ../../core/modules { inherit inputs username; })
    (import ./users.nix { inherit inputs username; })
    (import ./nix-config.nix { inherit inputs; })
  ];

  # Bluetooth
  services.blueman.enable = true;
  # Flatpak for unity
  services.flatpak.enable = true;
  # Battery status
  services.upower.enable = true;
  # USB
  services.gvfs.enable = true;
  services.udisks2.enable = true;
  programs.dconf.enable = true;
  services.dbus.enable = true;

  services.openssh.enable = true;
  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  #Hardware
  hardware = {
    bluetooth = {
      enable = true;
      powerOnBoot = true;
      settings = {
        General.Experimental = true;
      };
    };
    graphics.enable = true;
  };
  #Common Settings
  time.timeZone = "America/New_York";
  i18n.defaultLocale = "en_US.UTF-8";

  programs = {
    hyprland = {
        enable = true;
        xwayland.enable = true;
        package = inputs.hyprland.packages.${pkgs.system}.default;
        portalPackage = inputs.hyprland.packages.${pkgs.system}.xdg-desktop-portal-hyprland;
    };
  };

  xdg.portal = {
    enable = true;
    xdgOpenUsePortal= true;
    config = {
        common.default = ["gtk"];
        hyprland.default = ["hyprland" "gtk"];
    };
    extraPortals = with pkgs; [
        xdg-desktop-portal-gtk
    ];
  };

  systemd.user.services.xdg-desktop-portal-gtk = {
    wantedBy = [ "graphical-session.target" ];
  };


  # Configure AccountsService which handles user icons
  services.accounts-daemon.enable = true;

}
