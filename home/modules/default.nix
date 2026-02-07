{ pkgs, ... }: {


  imports = [
    (import ./bash.nix )
    (import ./claude.nix )
    (import ./eza.nix )
    (import ./git.nix )
    (import ./kitty.nix )
    (import ./nvf.nix )
    (import ./yazi.nix )
    (import ./btop.nix )
    (import ./zen-browser.nix )
    (import ./catppuccin.nix )
    (import ./stylix.nix )
    (import ./quickshell.nix )
    (import ./obs.nix )
    (import ./thunar.nix )
    (import ./virtualization.nix )
    (import ./vlc.nix )
    (import ./vscode.nix )
    (import ./zed.nix )
    (import ./spicetify.nix )
    (import ./docker-gui.nix )
    (import ./sops-manager.nix )
  ];
}
