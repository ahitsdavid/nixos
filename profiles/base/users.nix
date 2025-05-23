# profile/base/users.nix
{ inputs, username }:
{ config, pkgs, ... }: {
  # Define user account

  users.users.${username} = {
    isNormalUser = true;
    description = "David Thach";
    extraGroups = [ "networkmanager" "wheel" ];
  };
  
  # Allow sudo without password for wheel group (optional)
  security.sudo.wheelNeedsPassword = true;
}