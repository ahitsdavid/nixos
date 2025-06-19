# profiles/base/default.nix
{ inputs, username }:
{ config, pkgs, ... }: {
  imports = [
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
    pavucontrol   # Audio device control
    pciutils      # PCI Inspection
    unrar         # .rar file tool
    unzip         # .zip file tool
    usbutils      # USB Device tool
    glxinfo
    adwaita-icon-theme
    hicolor-icon-theme
    wget
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

  #programs.hyprland = {
  #  enable = true;
  #  xwayland.enable = true;
  #};
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
        # common.default = ["gtk"];
        hyprland.default = ["hyprland"];
    };

    extraPortals = [
        # pkgs.xdg-desktop-portal-gtk
    ];
  };

  # Fonts
  fonts = {
    packages = with pkgs; [
      accountsservice
      source-code-pro
      noto-fonts
      noto-fonts-cjk-sans
      twitter-color-emoji
      font-awesome
      powerline-fonts
      nerd-fonts.jetbrains-mono
      nerd-fonts.symbols-only
    ];
    fontconfig = {
      hinting.autohint = true;
    };
  };

  # Desktop Environment
  services.xserver.enable = true;
  #services.xserver.displayManager.gdm = {
  #  enable = true;
  #  wayland = true;
  #  # This enables user icons in GDM
  #  autoSuspend = false;
  #};
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
