# home/modules/starship-zsh.nix
# Lean Starship config for Zsh (no backgrounds, just colored text + icons)
# Fish uses the powerline config from starship.nix; Zsh gets this minimal style
{ config, pkgs, lib, ... }:

let
  tomlFormat = pkgs.formats.toml {};

  # Catppuccin Mocha palette (included directly since catppuccin module only affects programs.starship)
  catppuccinMocha = {
    rosewater = "#f5e0dc";
    flamingo = "#f2cdcd";
    pink = "#f5c2e7";
    mauve = "#cba6f7";
    red = "#f38ba8";
    maroon = "#eba0ac";
    peach = "#fab387";
    yellow = "#f9e2af";
    green = "#a6e3a1";
    teal = "#94e2d5";
    sky = "#89dceb";
    sapphire = "#74c7ec";
    blue = "#89b4fa";
    lavender = "#b4befe";
    text = "#cdd6f4";
    subtext1 = "#bac2de";
    subtext0 = "#a6adc8";
    overlay2 = "#9399b2";
    overlay1 = "#7f849c";
    overlay0 = "#6c7086";
    surface2 = "#585b70";
    surface1 = "#45475a";
    surface0 = "#313244";
    base = "#1e1e2e";
    mantle = "#181825";
    crust = "#11111b";
  };

  zshStarshipConfig = tomlFormat.generate "starship-zsh.toml" {
    palette = "catppuccin_mocha";

    format = lib.concatStrings [
      "$os"
      "$directory"
      "$git_branch"
      "$git_status"
      "$fill"
      "$cmd_duration"
      "$c"
      "$rust"
      "$golang"
      "$nodejs"
      "$python"
      "$nix_shell"
      "$time"
      "$line_break"
      "$character"
    ];

    os = {
      disabled = false;
      style = "fg:blue";
      symbols.NixOS = "󱄅 ";
    };

    directory = {
      style = "bold fg:blue";
      format = "[$path]($style)[$read_only]($read_only_style) ";
      truncation_length = 3;
      fish_style_pwd_dir_length = 1;
    };

    git_branch = {
      symbol = " ";
      style = "fg:mauve";
      format = "[$symbol$branch]($style)";
    };

    git_status = {
      style = "fg:yellow";
      format = "[ $all_status$ahead_behind]($style) ";
    };

    fill = {
      symbol = " ";
    };

    cmd_duration = {
      min_time = 3000;
      style = "fg:peach";
      format = "[$duration ]($style)";
    };

    c = {
      symbol = " ";
      style = "fg:teal";
      format = "[$symbol($version) ]($style)";
      detect_extensions = [];
      detect_files = [];
    };

    rust = {
      symbol = " ";
      style = "fg:peach";
      format = "[$symbol($version) ]($style)";
      detect_extensions = [];
      detect_files = [];
    };

    golang = {
      symbol = " ";
      style = "fg:sky";
      format = "[$symbol($version) ]($style)";
      detect_extensions = [];
      detect_files = [];
    };

    nodejs = {
      symbol = " ";
      style = "fg:green";
      format = "[$symbol($version) ]($style)";
      detect_extensions = [];
      detect_files = [];
    };

    python = {
      symbol = " ";
      style = "fg:yellow";
      format = "[$symbol($version) ]($style)";
      detect_extensions = [];
      detect_files = [];
    };

    nix_shell = {
      symbol = " ";
      style = "fg:sapphire";
      format = "[$symbol$state ]($style)";
    };

    time = {
      disabled = false;
      time_format = "%I:%M %p";
      style = "fg:overlay1";
      format = "[$time]($style)";
    };

    character = {
      success_symbol = "[❯](bold fg:mauve)";
      error_symbol = "[❯](bold fg:red)";
      vimcmd_symbol = "[❮](bold fg:green)";
    };

    line_break = {
      disabled = false;
    };

    palettes.catppuccin_mocha = catppuccinMocha;
  };
in
{
  xdg.configFile."starship-zsh.toml".source = zshStarshipConfig;
}
