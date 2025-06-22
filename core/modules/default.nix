# core/modules/default.nix
{ username }:
{ pkgs, ... }: {
  imports = [
    ( import ./fonts.nix )
    ( import ./greetd.nix )
    ( import ./packages.nix )
    ( import ./steam.nix )
  ];

}
  