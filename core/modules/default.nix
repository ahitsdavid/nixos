# core/modules/default.nix
{ inputs, username }:
{ pkgs, ... }: {
  imports = [
    ( import ./bootloader.nix )
    ( import ./fonts.nix )
    ( import ./greetd.nix )
    ( import ./networking.nix { inherit inputs; })
    ( import ./packages.nix { inherit inputs; })
    ( import ./pipewire.nix )
    ( import ./steam.nix )
    #( import ./stylix.nix )
  ];

}
  