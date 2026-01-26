{pkgs, ...}: {
  # Fonts
  fonts = {
    packages = with pkgs; [
      accountsservice
      source-code-pro
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-color-emoji  # Don't use twitter-color-emoji - it has broken fontconfig that makes emoji the primary font
      font-awesome
      powerline-fonts
      nerd-fonts.jetbrains-mono
      nerd-fonts.symbols-only
      material-symbols
      rubik
    ];
    fontconfig = {
      enable = true;
      hinting = {
        enable = true;
        autohint = true;
      };
    };
  };
}
