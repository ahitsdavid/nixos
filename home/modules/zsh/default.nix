#home/modules/zsh/default.nix 
#Zsh config
{ config, lib, pkgs, ... } :
{
    # Set up ZSH as an avilable shell
  programs.zsh = {
    enable = true;
    autocd = true;
    dotDir = ".config/zsh";
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    shellAliases = {
      ll = "ls -l";
      v = "nvim";
      sv = "sudo nvim";
      c = "clear";
      list-generations = "nixos-rebuild list-generations";
      collect-garbage = "sudo nix-collect-garbage -d";
    };

    history = {
      expireDuplicatesFirst = true;
      size = 10000000;
    };

    oh-my-zsh = {
      enable = true;
      plugins = [ 
        "git" 
        "docker" 
        "history" 
        "sudo" 
      ];
    };

    zplug = {
      enable = true;
      plugins = [
        { name = "zsh-users/zsh-autosuggestions"; }
        { name = "zsh-users/zsh-completions"; }
        { name = "zsh-users/zsh-syntax-highlighting"; }
        { name = "romkatv/powerlevel10k"; tags = [ as:theme depth:1 ]; }
      ];
    };
    
    plugins = [
      {
        name = "zsh-nix-shell";
        file = "nix-shell.plugin.zsh";
        src = pkgs.fetchFromGitHub {
          owner = "chisui";
          repo = "zsh-nix-shell";
          rev = "v0.8.0";
          sha256 = "1lzrn0n4fxfcgg65v0qhnj7wnybybqzs4adz7xsrkgmcsr0ii8b7";
        };
      }
      {
        name = "powerlevel10k";
        src = pkgs.zsh-powerlevel10k;
        file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
      }
      {
        name = "powerlevel10k-config";
        src = lib.cleanSource ./p10k-config;
        file = "p10k.zsh";
      }
    
    ];
  };
}
