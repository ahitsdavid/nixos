{ config, pkgs, ... }:

{
  programs.spicetify = {
    enable = true;
    
    # Let Stylix handle the theming automatically
    # The theme and colorScheme will be overridden by Stylix
  };
}