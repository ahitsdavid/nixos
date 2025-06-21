{ pkgs, ... }: {


  imports = [
    (import ./bash.nix )
    #(import ./dolphin.nix )
    (import ./eza.nix )
    (import ./kitty.nix )
    (import ./nvf.nix )
    (import ./yazi.nix )
    (import ./btop.nix )
    (import ./zen-browser.nix )
    (import ./catppuccin.nix )
    (import ./quickshell.nix )
    (import ./obs.nix )
    (import ./thunar.nix )
    (import ./virtualization.nix )
    (import ./vscode.nix )
    (import ./zed.nix )
  ];

  #programs.dolphin = {
  #  enable = true;
  #};
}
