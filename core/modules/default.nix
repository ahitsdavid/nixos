# core/modules/default.nix
{ pkgs, ... }: {
  imports = [
    ( import ./fonts.nix )
    ( import ./greetd.nix )
    ( import ./steam.nix )
  ];

}
  