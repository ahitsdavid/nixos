# core/modules/default.nix
{ pkgs, ... }: {
  imports = [
    (import ./steam.nix )
  ];

}
  