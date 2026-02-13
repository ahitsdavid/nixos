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

  # Helper to import user-vars for a given username
  getUserVars = name: import ./user-vars.nix name;

  # Build home-manager user config for a given user
  mkUserHomeConfig = { name, homeConfig, includeGaming, usesGnome, extraHomeModules ? [] }:
    let
      userVars = getUserVars name;
    in {
      imports = [
        stylix.homeModules.stylix
        catppuccin.homeModules.catppuccin
      ] ++ (if usesGnome then [] else [ inputs.spicetify-nix.homeManagerModules.default ])
        ++ [ homeConfig ]
        ++ (if includeGaming then [ ../home/gaming.nix ] else [])
        ++ extraHomeModules;
    };

  # Build system user account for an extra user
  mkExtraUserSystem = name:
    let
      userVars = getUserVars name;
      shellPkg = {
        fish = "fish";
        zsh = "zsh";
        bash = "bash";
      }.${userVars.shell} or "fish";
    in {
      users.users.${name} = {
        isNormalUser = true;
        description = userVars.description;
        extraGroups = userVars.extraGroups;
        shell = "/run/current-system/sw/bin/${shellPkg}";
      };
    };
in
{
  # Create a NixOS configuration with common modules
  # Reads capabilities from hosts/<hostname>/meta.nix
  # Auto-applies profiles based on meta flags
  mkNixosConfiguration = { hostname, extraModules ? [] }:
    let
      meta = getHostMeta hostname;
      # Existing flags
      includeGaming = meta.isGaming or false;
      hasNvidia = meta.hasNvidia or false;
      usesGnome = meta.usesGnome or false;
      extraUsers = meta.extraUsers or [];
      # New flags
      isLaptop = meta.isLaptop or false;
      isDevelopment = meta.isDevelopment or true;
      isWork = meta.isWork or true;
      hybridGpu = meta.hybridGpu or null;

      # Select home config based on desktop environment
      homeConfig = if usesGnome
                   then ../home/minimal.nix
                   else ../home/base.nix;
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

        # ── Auto-applied profiles ──

        # Base profile (always for GUI hosts)
        (import ../profiles/base { inherit inputs username; })

        # home-manager NixOS module
        home-manager.nixosModules.home-manager {
          home-manager.useGlobalPkgs = true;
          # Overwrite existing .backup files instead of failing
          home-manager.backupFileExtension = "backup";
          home-manager.backupCommand = "mv -f";
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = { inherit inputs username system; hostname = hostname; };

          # Primary user
          home-manager.users.${username} = mkUserHomeConfig {
            name = username;
            inherit homeConfig includeGaming usesGnome;
            extraHomeModules = extraModules.homeModules or [];
          };
        }

      ] # Conditional profiles
        ++ (if isDevelopment then [(import ../profiles/development { inherit inputs username; })] else [])
        ++ (if isWork then [(import ../profiles/work { inherit inputs username; })] else [])
        ++ (if isLaptop then [../profiles/laptop] else [])
        ++ (if usesGnome then [../profiles/gnome] else [])

        # GPU driver selection
        ++ (if hybridGpu != null then [
              (import ../core/drivers/hybrid-gpu.nix {
                mode = hybridGpu.mode;
                intelBusId = hybridGpu.intelBusId;
                nvidiaBusId = hybridGpu.nvidiaBusId;
              })
            ] else if hasNvidia then [
              ../core/drivers/nvidia.nix
              { drivers.nvidia.enable = true; }
            ] else [
              ../core/drivers/intel.nix
              { drivers.intel.enable = true; }
            ])

        # Extra users
        ++ (map (extraUser: {
              users.users.${extraUser} = let
                userVars = getUserVars extraUser;
              in {
                isNormalUser = true;
                description = userVars.description;
                extraGroups = userVars.extraGroups;
              };
              home-manager.users.${extraUser} = mkUserHomeConfig {
                name = extraUser;
                inherit homeConfig includeGaming usesGnome;
              };
            }) extraUsers)
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
