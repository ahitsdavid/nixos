# Display Manager Profile
# Default: SDDM with Wayland
#
# Available options:
#   ./sddm-wayland.nix  - SDDM with Wayland (default, for most hosts)
#   ./sddm-x11.nix      - SDDM with X11 (for hybrid GPU issues)
#
# Usage in host config:
#   imports = [ ../../profiles/display-manager ];           # default (wayland)
#   imports = [ ../../profiles/display-manager/sddm-x11.nix ];  # x11 variant
{ ... }:
{
  imports = [
    ./sddm-wayland.nix
  ];
}
