{ inputs }:
{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    adwaita-icon-theme    # GNOME's default icon theme
    bc                    # Basic calculator and math tool
    brightnessctl         # Screen Brightness control
    #claude-code           # Claude code
    cliphist              # Clipboard history manager for Wayland
    #catppuccin-gtk        # Catppucin GTK theme
    curl                  # Command-line tool for transferring data with URLs
    efibootmgr            # EFI boot manager for UEFI systems
    ffmpeg                # Video / Audio
    file                  # File type identification utility
    git                   # Distributed version control system
    mesa-demos            # OpenGL information utility (includes glxinfo)
    gnupg                 # GNU Privacy Guard - encryption and signing tool
    gptfdisk              # GPT partitioning tool (gdisk)
    tuigreet              # Terminal UI greeter for greetd display manager
    hicolor-icon-theme    # Freedesktop icon theme specification
    htop                  # Interactive process viewer and system monitor
    jq                    # Command-line JSON processor
    killall               # Blanket process kill
    lshw                  # Detailed hardware information
    lxqt.pavucontrol-qt   # Audio device control
    mutagen               # Audio metadata tag editor
    ncspot                # Spotify terminal client
    nextcloud-client      # Nextcloud desktop sync client
    nwg-displays          # configure monitor configs via GUI
    os-prober             # Operating system detection utility
    parted                # Disk partitioning tool
    pciutils              # PCI Inspection
    rsync                 # File synchronization and transfer tool
    sbctl                 # Secure Boot key manager
    tree                  # Directory tree visualization tool
    unrar                 # .rar file tool
    unzip                 # .zip file tool
    usbutils              # USB Device tool
    wget                  # Network downloader
    zip                   # File compression utility
    inputs.rose-pine-hyprcursor.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];
}
