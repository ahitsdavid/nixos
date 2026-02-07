# core/modules/default.nix
{ inputs, username }:
{ pkgs, ... }: {
  imports = [
    ( import ./bootloader.nix )
    ./ethernet-share.nix
    ( import ./fonts.nix )
    ( import ./networking.nix { inherit inputs; })
    ( import ./packages.nix { inherit inputs; })
    ( import ./pipewire.nix )
    ( import ./sops.nix )
    ( import ./steam.nix )
    ( import ./tailscale.nix )
    ( import ./vlc.nix )
    ( import ./yubikey.nix )
  ];

}
  