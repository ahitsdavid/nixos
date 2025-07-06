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
      # Let Stylix handle default fonts
      # defaultFonts will be managed by Stylix configuration
    };
  };
}
