#!/usr/bin/env bash
# Quick rebuild script for Docker GUI support

set -e

echo "Rebuilding NixOS configuration with Docker GUI support..."

# Rebuild the system targeting thinkpad profile
sudo nixos-rebuild switch --flake .#thinkpad

echo "Docker GUI support has been installed!"
echo ""
echo "Available commands after rebuild:"
echo "  run-qt-docker <image> <command>  - Run Qt apps with auto-detection"
echo "  docker-gui <args>                - Run Docker with X11 forwarding"
echo "  docker-wayland <args>            - Run Docker with Wayland forwarding"
echo ""
echo "Example usage:"
echo "  run-qt-docker qt-crosscompile-simple /workspace/example-qt5/install-linux-qt5/bin/QtCrossCompileExampleQt5"
echo ""
echo "Note: The scripts will be available in ~/.local/bin/ after the rebuild."