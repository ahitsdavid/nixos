# core/modules/default.nix
{ inputs, username }:
{ pkgs, ... }: {
  imports = [
    ./bootloader.nix
    ./ethernet-share.nix
    ./fonts.nix
    (import ./networking.nix { inherit inputs; })
    (import ./packages.nix { inherit inputs; })
    ./pipewire.nix
    ./sops.nix
    ./steam.nix
    ./tailscale.nix
    ./vlc.nix
    ./yubikey.nix
  ];
}
  