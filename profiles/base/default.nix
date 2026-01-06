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

  # Common packages for all configurations
  environment.systemPackages = with pkgs; [
    # Use discord for thinkpad (webcord is broken), webcord for others
    (if config.networking.hostName == "thinkpad" then discord else webcord)
  ];

  #Handles DNS Configuraiton
  networking.resolvconf.enable = false;

  environment.etc."resolv.conf".text = ''
    nameserver 8.8.8.8
    nameserver 1.1.1.1
  '';
  
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
        package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.default;
        portalPackage = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
    };
  };

  xdg.portal = {
    enable = true;
    xdgOpenUsePortal = false;  # Disabled - portal doesn't provide OpenURI interface
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
