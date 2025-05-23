{profile, ...}: {
  programs.bash = {
    enable = false;
    enableCompletion = true;
    initExtra = ''
      fastfetch
    '';
    shellAliases = {
      sv = "sudo nvim";
      ncg = "nix-collect-garbage --delete-old && sudo nix-collect-garbage -d && sudo /run/current-system/bin/switch-to-configuration boot";
      v = "nvim";
      ".." = "cd ..";
    };
  };
}
