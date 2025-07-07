{ config, pkgs, ... }:

{
  programs.spicetify = {
    enable = true;
    
    # Let Stylix handle the theming automatically
    # The theme and colorScheme will be overridden by Stylix
    
    # Enable common extensions
    enabledExtensions = with config.programs.spicetify.extensions; [
      adblock
      hidePodcasts
      shuffle
      keyboardShortcut
    ];
    
    # Enable common custom apps
    enabledCustomApps = with config.programs.spicetify.customApps; [
      newReleases
      betterLibrary
    ];
  };
}