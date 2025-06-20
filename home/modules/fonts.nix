#home/modules/fonts.nix 
{ pkgs, ... } :
{
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
      hinting.autohint = true;
    };
  };
}