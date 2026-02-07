# lib/host-builders.nix
# Helper functions for building NixOS and Home Manager configurations
{
  nixpkgs,
  inputs,
  system,
  username,
  nurpkgs,
  catppuccin,
  stylix,
  home-manager,
}:
let
  # Helper to get host metadata from hosts/<hostname>/meta.nix
  getHostMeta = hostname:
    let path = ../hosts/${hostname}/meta.nix;
    in if builtins.pathExists path then import path else {};
in
{
  # Create a NixOS configuration with common modules
  # Reads capabilities from hosts/<hostname>/meta.nix (isGaming, hasNvidia, etc.)
  mkNixosConfiguration = { hostname, extraModules ? [] }:
    let
      meta = getHostMeta hostname;
      includeGaming = meta.isGaming or false;
      hasNvidia = meta.hasNvidia or false;
    in
    nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = { inherit inputs username; };
      modules = [
        # Configure nixpkgs at the system level
        {
          nixpkgs.overlays = [ nurpkgs.overlays.default ];
          nixpkgs.config = {
            allowUnfree = true;
            permittedInsecurePackages = [
              "qtwebengine-5.15.19"
              "electron-36.9.5"
            ];
          };
        }

        stylix.nixosModules.stylix
        inputs.sops-nix.nixosModules.sops

        # Host-specific configuration
        ../hosts/${hostname}

        # Catppuccin theming
        catppuccin.nixosModules.catppuccin

        # home-manager NixOS module
        home-manager.nixosModules.home-manager {
          home-manager.useGlobalPkgs = true;
          # Overwrite existing .backup files instead of failing
          home-manager.backupFileExtension = "backup";
          home-manager.backupCommand = "mv -f";
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = { inherit inputs username system; hostname = hostname; };
          home-manager.users.${username} = {
            imports = [
              stylix.homeModules.stylix
              catppuccin.homeModules.catppuccin
              inputs.spicetify-nix.homeManagerModules.default
              ../home/base.nix
            ] ++ (if includeGaming then [ ../home/gaming.nix ] else [])
              ++ (extraModules.homeModules or []);
          };
        }
      ] ++ (if hasNvidia then [{ drivers.nvidia.enable = true; }] else [])
        ++ (extraModules.systemModules or []);
    };

  # Create a headless NixOS configuration (no GUI, no home-manager)
  mkHeadlessConfiguration = { hostname }:
    nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = { inherit inputs username; };
      modules = [
        { nixpkgs.config.allowUnfree = true; }
        inputs.sops-nix.nixosModules.sops
        ../hosts/${hostname}
      ];
    };
}
