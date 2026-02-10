{ pkgs, ... }: {
  # Packages needed for Docker GUI app support
  home.packages = with pkgs; [
    xhost        # X11 access control (for X11 forwarding)
    xauth        # X11 authentication
    xwayland          # X11 apps on Wayland (should already be available via Hyprland)
  ];

  # Create a helper script for running Docker GUI apps
  home.file.".local/bin/docker-gui" = {
    text = ''
      #!/usr/bin/env bash
      # Docker GUI App Runner for Hyprland/Wayland
      
      # Set up X11 forwarding for Docker containers
      export DISPLAY=:0
      
      # Allow X11 connections from Docker containers
      ${pkgs.xhost}/bin/xhost +local:docker 2>/dev/null || true

      # Run the Docker command with X11 forwarding
      exec ${pkgs.docker}/bin/docker run \
          --rm \
          -e DISPLAY=$DISPLAY \
          -e QT_X11_NO_MITSHM=1 \
          -v /tmp/.X11-unix:/tmp/.X11-unix:rw \
          -v "$HOME/.Xauthority:/root/.Xauthority:ro" \
          "$@"
    '';
    executable = true;
  };

  # Alternative script for running with Wayland native support
  home.file.".local/bin/docker-wayland" = {
    text = ''
      #!/usr/bin/env bash
      # Docker Wayland App Runner
      
      # Set up Wayland socket forwarding
      export WAYLAND_DISPLAY=$WAYLAND_DISPLAY
      export XDG_RUNTIME_DIR=$XDG_RUNTIME_DIR
      
      # Run the Docker command with Wayland forwarding
      exec ${pkgs.docker}/bin/docker run \
          --rm \
          -e WAYLAND_DISPLAY=$WAYLAND_DISPLAY \
          -e XDG_RUNTIME_DIR=/tmp \
          -e QT_QPA_PLATFORM=wayland \
          -v "$XDG_RUNTIME_DIR/$WAYLAND_DISPLAY:/tmp/$WAYLAND_DISPLAY:ro" \
          "$@"
    '';
    executable = true;
  };

  # Qt-specific Docker runner for our cross-compilation setup
  home.file.".local/bin/run-qt-docker" = {
    text = ''
      #!/usr/bin/env bash
      # Qt Docker App Runner - tries Wayland first, falls back to X11
      
      set -e
      
      if [ -z "$1" ]; then
          echo "Usage: run-qt-docker <docker-image> [command...]"
          echo "Example: run-qt-docker qt-crosscompile-simple /workspace/example-qt5/install-linux-qt5/bin/QtCrossCompileExampleQt5"
          exit 1
      fi
      
      IMAGE="$1"
      shift
      
      echo "Trying to run Qt app with Wayland support..."
      
      # First try Wayland
      if [ -n "$WAYLAND_DISPLAY" ]; then
          echo "Attempting Wayland display..."
          ${pkgs.docker}/bin/docker run \
              --rm \
              -e WAYLAND_DISPLAY=$WAYLAND_DISPLAY \
              -e XDG_RUNTIME_DIR=/tmp \
              -e QT_QPA_PLATFORM=wayland \
              -v "$XDG_RUNTIME_DIR/$WAYLAND_DISPLAY:/tmp/$WAYLAND_DISPLAY:ro" \
              -v "$(pwd):/workspace" \
              "$IMAGE" "$@" && exit 0
      fi
      
      echo "Wayland failed, trying X11 forwarding..."
      
      # Fallback to X11
      export DISPLAY=:0
      ${pkgs.xhost}/bin/xhost +local:docker 2>/dev/null || true

      ${pkgs.docker}/bin/docker run \
          --rm \
          -e DISPLAY=$DISPLAY \
          -e QT_X11_NO_MITSHM=1 \
          -v /tmp/.X11-unix:/tmp/.X11-unix:rw \
          -v "$HOME/.Xauthority:/root/.Xauthority:ro" \
          -v "$(pwd):/workspace" \
          "$IMAGE" "$@"
    '';
    executable = true;
  };
}