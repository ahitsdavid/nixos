# lib/user-vars.nix
# Safe import helper for user variables with sensible defaults.
# Usage: userVars = import ../lib/user-vars.nix username;
#
# Imports home/users/<username>/variables.nix and provides fallback
# defaults so builds never break even with a minimal variables file.
username:
let
  path = ../home/users/${username}/variables.nix;
  raw = if builtins.pathExists path then import path else {};
in
{
  # Identity
  fullName = raw.fullName or raw.gitUsername or username;
  description = raw.description or raw.fullName or raw.gitUsername or username;
  gitUsername = raw.gitUsername or raw.fullName or username;
  gitEmail = raw.gitEmail or "${username}@localhost";

  # System
  shell = raw.shell or "fish";
  extraGroups = raw.extraGroups or [ "networkmanager" "wheel" "docker" "libvirtd" "keys" ];

  # Hyprland
  extraMonitorSettings = raw.extraMonitorSettings or "";

  # Programs
  browser = raw.browser or "firefox";
  terminal = raw.terminal or "kitty";
  file-manager = raw.file-manager or "yazi";
  keyboardLayout = raw.keyboardLayout or "us";
  consoleKeyMap = raw.consoleKeyMap or "us";

  # Wallpaper
  wallpaper = raw.wallpaper or "Pictures/Wallpapers/yosemite.png";
}
