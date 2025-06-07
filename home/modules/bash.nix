{profile, ...}: {
  programs.bash = {
    enable = true;
    enableCompletion = true;
    initExtra = ''
      fastfetch
      zsh
    '';
    shellAliases = {
      sv = "sudo nvim";
      ncg = "nix-collect-garbage --delete-old && sudo nix-collect-garbage -d && sudo /run/current-system/bin/switch-to-configuration boot";
      v = "nvim";
      ".." = "cd ..";
    };
  };
}
