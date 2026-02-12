# profile/base/users.nix
{ inputs, username }:
{ config, pkgs, lib, ... }:
let
  userVars = import ../../lib/user-vars.nix username;

  # Check if user password hash secret exists (fork-friendly)
  hasUserPassword = (lib.hasAttr "users/${username}/password_hash" (config.sops.secrets or {}));

  # Map shell name string to package
  shellPkg = {
    fish = pkgs.fish;
    zsh = pkgs.zsh;
    bash = pkgs.bash;
  }.${userVars.shell} or pkgs.fish;
in
{
  # Enable the user's chosen shell
  programs.fish.enable = lib.mkDefault (userVars.shell == "fish");
  programs.zsh.enable = lib.mkDefault (userVars.shell == "zsh");

  # Define user account
  users.users.${username} = {
    isNormalUser = true;
    description = userVars.description;
    extraGroups = userVars.extraGroups;
    shell = shellPkg;

    # Use password hash from SOPS if available
    hashedPasswordFile = lib.mkIf hasUserPassword
      config.sops.secrets."users/${username}/password_hash".path;
  };

  # Allow sudo without password for wheel group (optional)
  security.sudo.wheelNeedsPassword = true;
}
