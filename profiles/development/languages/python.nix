#profiles/development/languages/python.nix
{ inputs }:
{ config, pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    python3
    python3Packages.pip
    python3Packages.ipython
    python3Packages.black
    python3Packages.pylint
    python3Packages.pywayland
    python3Packages.setproctitle
    # poetry  # Temporarily disabled due to pbs-installer version conflict (2026.1.13 > 2026.0.0)
    # Alternative: use python3Packages.poetry-core if you need poetry functionality
  ];
}