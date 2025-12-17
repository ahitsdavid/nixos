# core/modules/default.nix
{ inputs, username }:
{ pkgs, ... }: {
  imports = [
    ( import ./bootloader.nix )
    ( import ./fonts.nix )
    #( import ./greetd.nix )
    ( import ./sddm.nix )
    ( import ./networking.nix { inherit inputs; })
    ( import ./packages.nix { inherit inputs; })
    ( import ./pipewire.nix )
    ( import ./sops.nix )
    ( import ./steam.nix )
    #( import ./stylix.nix )
    ( import ./tailscale.nix )
    ( import ./yubikey.nix )
  ];

}
  