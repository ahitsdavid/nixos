{pkgs, ...}: {
  # Fonts
  fonts = {
    packages = with pkgs; [
      accountsservice
      source-code-pro
      noto-fonts
      noto-fonts-cjk-sans
      twitter-color-emoji
      font-awesome
      powerline-fonts
      nerd-fonts.jetbrains-mono
      nerd-fonts.symbols-only
    ];
    fontconfig = {
      enable = true;
      hinting = {
        enable = true;
        autohint = true;
      };
      defaultFonts = {
        monospace = [ "JetBrainsMono Nerd Font" ];
        sansSerif = [ "JetBrainsMono Nerd Font" "Noto Sans" ];
        serif = [ "JetBrainsMono Nerd Font" "Noto Serif" ];
      };
    };
  };
}
