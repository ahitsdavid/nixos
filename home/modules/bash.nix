{ username, ... }:

let
  sharedAliases = import ./shell-aliases.nix { inherit username; };
in
{
  programs.bash = {
    enable = true;
    enableCompletion = true;
    initExtra = ''
      # Bash configuration - keeping minimal since zsh is primary shell
    '';
    shellAliases = sharedAliases.shellAliases // {
      # Bash-specific aliases
      ncg = "nix-collect-garbage --delete-old && sudo nix-collect-garbage -d && sudo /run/current-system/bin/switch-to-configuration boot";
      ".." = "cd ..";
    };
  };
}
