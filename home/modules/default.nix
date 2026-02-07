{ pkgs, ... }: {
  imports = [
    ./bash.nix
    ./claude.nix
    ./eza.nix
    ./git.nix
    ./kitty.nix
    ./nvf.nix
    ./yazi.nix
    ./btop.nix
    ./zen-browser.nix
    ./catppuccin.nix
    ./stylix.nix
    ./quickshell.nix
    ./obs.nix
    ./thunar.nix
    ./virtualization.nix
    ./vlc.nix
    ./vscode.nix
    ./zed.nix
    ./spicetify.nix
    ./docker-gui.nix
    ./sops-manager.nix
  ];
}
