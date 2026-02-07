# home/modules/starship.nix
# Starship prompt - enabled for Fish only (Zsh uses powerlevel10k)
{ config, pkgs, lib, ... }:

{
  programs.starship = {
    enable = true;

    # Only enable for Fish, not Zsh (which uses p10k)
    enableZshIntegration = false;
    enableFishIntegration = true;
    enableBashIntegration = false;

    # Catppuccin colors handled by catppuccin.nix module
    # We just define the prompt format here

    settings = {
      # Prompt format
      format = lib.concatStrings [
        "[](blue)"
        "$os"
        "$username"
        "[](bg:sapphire fg:blue)"
        "$directory"
        "[](fg:sapphire bg:surface1)"
        "$git_branch"
        "$git_status"
        "[](fg:surface1 bg:surface0)"
        "$python"
        "$nodejs"
        "$rust"
        "$golang"
        "$nix_shell"
        "[](fg:surface0)"
        "$fill"
        "$cmd_duration"
        "$line_break"
        "$character"
      ];

      # OS icon
      os = {
        disabled = false;
        style = "bg:blue fg:base";
        symbols.NixOS = " ";
      };

      # Username
      username = {
        show_always = true;
        style_user = "bg:blue fg:base";
        style_root = "bg:red fg:base";
        format = "[ $user ]($style)";
      };

      # Directory
      directory = {
        style = "bg:sapphire fg:base";
        format = "[ $path ]($style)";
        truncation_length = 3;
        truncation_symbol = ".../";
        substitutions = {
          Documents = "󰈙 ";
          Downloads = " ";
          Music = " ";
          Pictures = " ";
          nixos = " ";
        };
      };

      # Git
      git_branch = {
        symbol = "";
        style = "bg:surface1 fg:text";
        format = "[ $symbol $branch ]($style)";
      };

      git_status = {
        style = "bg:surface1 fg:text";
        format = "[$all_status$ahead_behind ]($style)";
      };

      # Languages
      python = {
        symbol = "";
        style = "bg:surface0 fg:yellow";
        format = "[ $symbol ($version) ]($style)";
      };

      nodejs = {
        symbol = "";
        style = "bg:surface0 fg:green";
        format = "[ $symbol ($version) ]($style)";
      };

      rust = {
        symbol = "";
        style = "bg:surface0 fg:peach";
        format = "[ $symbol ($version) ]($style)";
      };

      golang = {
        symbol = "";
        style = "bg:surface0 fg:sky";
        format = "[ $symbol ($version) ]($style)";
      };

      # Nix shell indicator
      nix_shell = {
        symbol = "";
        style = "bg:surface0 fg:blue";
        format = "[ $symbol $state ]($style)";
      };

      # Right side fill
      fill = {
        symbol = " ";
      };

      # Command duration
      cmd_duration = {
        min_time = 500;
        style = "fg:overlay1";
        format = "[$duration]($style)";
      };

      # Prompt character
      character = {
        success_symbol = "[❯](bold green)";
        error_symbol = "[❯](bold red)";
      };

      # Line break between segments and input
      line_break = {
        disabled = false;
      };
    };
  };

  # Let Catppuccin module handle starship theming
  catppuccin.starship.enable = true;
}
