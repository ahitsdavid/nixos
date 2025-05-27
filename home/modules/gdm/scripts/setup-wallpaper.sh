#!/usr/bin/env bash
set -euo pipefail

# Check if the wallpaper path is provided
if [ $# -ne 1 ]; then
  echo "Usage: $0 <wallpaper-path>"
  exit 1
fi

WALLPAPER_PATH="$1"

# Check if the wallpaper file exists (including if it's a symlink)
if [ ! -e "$WALLPAPER_PATH" ]; then
  echo "Error: Wallpaper file does not exist: $WALLPAPER_PATH"
  exit 1
fi

# Resolve the symlink to get the real path if it's a symlink
if [ -L "$WALLPAPER_PATH" ]; then
  REAL_WALLPAPER_PATH=$(readlink -f "$WALLPAPER_PATH")
  echo "Wallpaper is a symlink, resolving to: $REAL_WALLPAPER_PATH"
else
  REAL_WALLPAPER_PATH="$WALLPAPER_PATH"
fi

# Set the GDM background
GDM_CONFIG_DIR="/etc/dconf/db/gdm.d"
mkdir -p "$GDM_CONFIG_DIR"

cat > "$GDM_CONFIG_DIR/01-background" << EOF
[org/gnome/desktop/background]
picture-uri='file://$REAL_WALLPAPER_PATH'
picture-uri-dark='file://$REAL_WALLPAPER_PATH'
picture-options='zoom'
EOF

# Update dconf database
dconf update

echo "GDM wallpaper set to: $REAL_WALLPAPER_PATH"
