#!/usr/bin/env bash

# This script sets up GDM face icon for a user
# Arguments:
#   $1: username
#   $2: session name

USERNAME="$1"
SESSION="$2"

# Create required directories
mkdir -p /var/lib/AccountsService/icons
mkdir -p /var/lib/AccountsService/users

# Copy the actual file content, not the symlink
if [ -L "/home/${USERNAME}/.face" ]; then
  # Get the target of the symlink and copy it
  cp -L "/home/${USERNAME}/.face" "/var/lib/AccountsService/icons/${USERNAME}"
elif [ -f "/home/${USERNAME}/.face" ]; then
  # Direct copy if it's a regular file
  cp "/home/${USERNAME}/.face" "/var/lib/AccountsService/icons/${USERNAME}"
fi

# Set proper permissions
chmod 644 "/var/lib/AccountsService/icons/${USERNAME}"
chown root:root "/var/lib/AccountsService/icons/${USERNAME}"

# Create or update the user file
cat > "/var/lib/AccountsService/users/${USERNAME}" << EOF
[User]
Session=${SESSION}
Icon=/var/lib/AccountsService/icons/${USERNAME}
SystemAccount=false
EOF

chmod 644 "/var/lib/AccountsService/users/${USERNAME}"
chown root:root "/var/lib/AccountsService/users/${USERNAME}"
