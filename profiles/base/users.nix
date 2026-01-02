# profile/base/users.nix
{ inputs, username }:
{ config, pkgs, lib, ... }:
let
  # Check if user password hash secret exists (fork-friendly)
  hasUserPassword = (lib.hasAttr "users/${username}/password_hash" (config.sops.secrets or {}));
in
{
  # Define user account
  users.users.${username} = {
    isNormalUser = true;
    description = "David Thach";
    extraGroups = [ "networkmanager" "wheel" "docker" "libvirtd" "keys" ];

    # Use password hash from SOPS if available
    hashedPasswordFile = lib.mkIf hasUserPassword
      config.sops.secrets."users/${username}/password_hash".path;
  };
  
  # Allow sudo without password for wheel group (optional)
  security.sudo.wheelNeedsPassword = true;
}