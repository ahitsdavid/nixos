# home/modules/starship.nix
# Starship prompt - Catppuccin Mocha powerline
# Adapted from: https://starship.rs/presets/catppuccin-powerline
{ config, pkgs, lib, ... }:

{
  programs.starship = {
    enable = true;

    # Only enable for Fish, not Zsh (which uses p10k)
    enableZshIntegration = false;
    enableFishIntegration = true;
    enableBashIntegration = false;

    settings = {
      # Catppuccin Mocha gradient: blue -> mauve -> pink -> flamingo -> rosewater -> lavender
      format = lib.concatStrings [
        "[](blue)"
        "$os"
        "$username"
        "[](bg:mauve fg:blue)"
        "$directory"
        "[](bg:pink fg:mauve)"
        "$git_branch"
        "$git_status"
        "[](fg:pink bg:flamingo)"
        "$c"
        "$rust"
        "$golang"
        "$nodejs"
        "$python"
        "$nix_shell"
        "[](fg:flamingo bg:rosewater)"
        "$docker_context"
        "[](fg:rosewater bg:lavender)"
        "$time"
        "[ ](fg:lavender)"
        "$fill"
        "$cmd_duration"
        "$line_break"
        "$character"
      ];

      # OS icon
      os = {
        disabled = false;
        style = "bg:blue fg:crust";
        symbols.NixOS = " ";
      };

      # Username
      username = {
        show_always = true;
        style_user = "bg:blue fg:crust";
        style_root = "bg:blue fg:crust";
        format = "[ $user ]($style)";
      };

      # Directory - fish-style abbreviation
      directory = {
        style = "bg:mauve fg:crust";
        format = "[ $path ]($style)";
        truncation_length = 3;
        truncation_symbol = "…/";
        fish_style_pwd_dir_length = 1;
        substitutions = {
          Documents = "󰈙 ";
          Downloads = " ";
          Music = " ";
          Pictures = " ";
          Developer = " ";
        };
      };

      # Git
      git_branch = {
        symbol = "";
        style = "bg:pink";
        format = "[[ $symbol $branch ](fg:crust bg:pink)]($style)";
      };

      git_status = {
        style = "bg:pink";
        format = "[[($all_status$ahead_behind )](fg:crust bg:pink)]($style)";
      };

      # Languages
      c = {
        symbol = " ";
        style = "bg:flamingo";
        format = "[[ $symbol( $version) ](fg:crust bg:flamingo)]($style)";
      };

      rust = {
        symbol = "";
        style = "bg:flamingo";
        format = "[[ $symbol( $version) ](fg:crust bg:flamingo)]($style)";
      };

      golang = {
        symbol = "";
        style = "bg:flamingo";
        format = "[[ $symbol( $version) ](fg:crust bg:flamingo)]($style)";
      };

      nodejs = {
        symbol = "";
        style = "bg:flamingo";
        format = "[[ $symbol( $version) ](fg:crust bg:flamingo)]($style)";
      };

      python = {
        symbol = "";
        style = "bg:flamingo";
        format = "[[ $symbol( $version) ](fg:crust bg:flamingo)]($style)";
      };

      # Nix shell indicator
      nix_shell = {
        symbol = "";
        style = "bg:flamingo";
        format = "[[ $symbol $state ](fg:crust bg:flamingo)]($style)";
      };

      # Docker context
      docker_context = {
        symbol = "";
        style = "bg:rosewater";
        format = "[[ $symbol( $context) ](fg:crust bg:rosewater)]($style)";
      };

      # Time
      time = {
        disabled = false;
        time_format = "%R";
        style = "bg:lavender";
        format = "[[  $time ](fg:crust bg:lavender)]($style)";
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
        success_symbol = "[❯](bold fg:green)";
        error_symbol = "[❯](bold fg:red)";
        vimcmd_symbol = "[❮](bold fg:green)";
      };

      # Two-line prompt
      line_break = {
        disabled = false;
      };
    };
  };

  # Catppuccin module provides the Mocha palette
  catppuccin.starship.enable = true;
}
