# profiles/base/default.nix
{ inputs, username }:
{ config, pkgs, ... }: {
  imports = [
    (import ../../core/modules { inherit username })
    (import ./users.nix { inherit inputs username; })
    (import ./networking.nix { inherit inputs; })
    (import ./nix-config.nix { inherit inputs; })
  ];

  environment.systemPackages = with pkgs; [
    brightnessctl # Screen Brightness control
    ffmpeg        # Video / Audio
    killall       # Blanket process kill
    lshw          # Detailedhardware information
    nwg-displays  # configure monitor configs via GUI
    lxqt.pavucontrol-qt# Audio device control
    pciutils      # PCI Inspection
    unrar         # .rar file tool
    unzip         # .zip file tool
    usbutils      # USB Device tool
    axel
    bc
    glxinfo
    adwaita-icon-theme
    hicolor-icon-theme
    wget
    cliphist
    jq
    mutagen
    greetd.tuigreet
    curl
    git
    htop
    file
    zip
    unzip
    gnupg
    vlc
    efibootmgr
    os-prober
    parted
    gptfdisk
    sbctl
    rsync
    tree
    inputs.rose-pine-hyprcursor.packages.${pkgs.system}.default
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

  # Bootloader.
  boot.loader = {
    systemd-boot = {
      enable = true;
      configurationLimit = 10;
      editor = false;
    };
    efi = {
      canTouchEfiVariables = true;
      efiSysMountPoint = "/boot";
    };

    # boot menu timeout
    timeout = 5;
  };

  # Preserve old generations for rollbacks
  boot.bootspec.enable = true;

  # Enable sound with pipewire.
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

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
  # Login Environment
  services.greetd = {
    enable = true;
    vt = 3;
    settings = {
      default_session = {
        user = username;
        command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --cmd Hyprland"; # start Hyprland with a TUI login manager
      };
    };
  };

  # Configure AccountsService which handles user icons
  services.accounts-daemon.enable = true;

}
