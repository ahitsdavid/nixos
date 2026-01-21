#profiles/development/languages/python.nix
{ inputs }:
{ config, pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    python3
    python3Packages.pip
    python3Packages.ipython
    python3Packages.pywayland
    python3Packages.setproctitle

    # Formatting & Linting
    ruff              # Fast linter + formatter (replaces black/pylint)

    # Type checking
    python3Packages.mypy

    # Testing
    python3Packages.pytest

    # Debugging
    python3Packages.debugpy

    # Package management
    uv                # Modern fast Python package manager
  ];
}