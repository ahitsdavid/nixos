{ pkgs, ... }: {

  
  imports = [
    (import ./bash.nix)
    (import ./kitty.nix )
    (import ./nvf.nix )
    (import ./yazi.nix )
    (import ./btop.nix )
    (import ./zen-browser.nix )
    (import ./catppuccin.nix )
    (import ./quickshell.nix )
    #(import ./virtualization.nix )
  ];
}