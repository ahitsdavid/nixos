#profiles/development/languages/python.nix
{ inputs }:
{ config, pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    python3
    python3Packages.pip
    python3Packages.ipython
    python3Packages.black
    python3Packages.pylint
    poetry
  ];
}