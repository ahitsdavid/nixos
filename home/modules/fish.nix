# home/modules/fish.nix
# Fish shell - complements Zsh with built-in features
{ config, pkgs, ... }:

let
  sharedAliases = import ./shell-aliases.nix;
in
{
  programs.fish = {
    enable = true;

    # Shared aliases with Zsh
    shellAliases = sharedAliases.shellAliases;

    # Fish functions (more powerful than aliases)
    functions = {
      # Quick rebuild current host
      rebuild = {
        description = "Rebuild NixOS configuration";
        body = ''
          cd ~/nixos
          git add -A
          sudo nixos-rebuild switch --flake .#(hostname)
        '';
      };

      # Quick flake update + rebuild
      update = {
        description = "Update flake and rebuild";
        body = ''
          cd ~/nixos
          nix flake update
          git add -A
          sudo nixos-rebuild switch --flake .#(hostname)
        '';
      };
    };

    interactiveShellInit = ''
      # Disable greeting
      set -g fish_greeting

      # Run fastfetch on new shell (same as Zsh)
      fastfetch
    '';
  };

  # Catppuccin theme for Fish
  catppuccin.fish.enable = true;
}
