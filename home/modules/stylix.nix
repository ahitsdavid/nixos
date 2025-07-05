# home/modules/stylix.nix - Home-manager Stylix configuration
{ config, pkgs, ... }: {
  # Home-manager Stylix configuration
  stylix = {
    # Use the same base16 scheme as system config
    base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";
    
    # Home-manager specific targets
    targets = {
      kitty.enable = true;
      # Add other home-manager stylix targets here as needed
    };
  };
}