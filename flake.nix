{
  description = "NixOS Configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    nixpkgs-unfree = {
      url = "github:numtide/nixpkgs-unfree";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    stylix = {
      url = "github:danth/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nurpkgs.url = "github:nix-community/NUR";
    nvf = {
      url = "github:notashelf/nvf";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprland = {
        type = "git";
        url = "https://github.com/hyprwm/Hyprland";
        ref = "refs/tags/v0.53.1";
        submodules = true;
    };
    aagl = {
      url = "github:ezKEa/aagl-gtk-on-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprland-plugins = {
      url = "github:hyprwm/hyprland-plugins";
      inputs.hyprland.follows = "hyprland";
    };
    hypr-dynamic-cursors = {
      url = "github:VirtCode/hypr-dynamic-cursors";
      inputs.hyprland.follows = "hyprland" ;  
    }; 
    rose-pine-hyprcursor = {
      url = "github:ndom91/rose-pine-hyprcursor";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.hyprlang.follows = "hyprland/hyprlang";
    };
    catppuccin = {
      url = "github:catppuccin/nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zen-browser.url = "github:0xc000022070/zen-browser-flake";
    sops-nix.url = "github:Mic92/sops-nix";
    quickshell = {
      url = "git+https://git.outfoxxed.me/quickshell/quickshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    spicetify-nix = {
      url = "github:Gerg-L/spicetify-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    pokerogue-app.url = "github:Admiral-Billy/Pokerogue-App";
    dots-hyprland = {
      type = "git";
      url = "https://github.com/end-4/dots-hyprland";
      submodules = true;
      flake = false;
    };
  };

  outputs = { 
    self, 
    nixpkgs, 
    home-manager,
    nurpkgs,
    catppuccin,
    stylix,
    ... 
    } @ inputs: 
  let
    system = "x86_64-linux";
    username = "davidthach";

    # Helper to get host metadata
    getHostMeta = hostname:
      let path = ./hosts/${hostname}/meta.nix;
      in if builtins.pathExists path then import path else {};

    # Create a function to make a NixOS configuration with common modules
    # Now reads capabilities from hosts/<hostname>/meta.nix
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
          ./hosts/${hostname}

          # Catpuccin theming
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
                ./home/base.nix
              ] ++ (if includeGaming then [ ./home/gaming.nix ] else [])
                ++ (extraModules.homeModules or []);
            };
          }
        ] ++ (if hasNvidia then [{ drivers.nvidia.enable = true; }] else [])
          ++ (extraModules.systemModules or []);
      };

    # Create a function for headless servers (no GUI, no home-manager)
    mkHeadlessConfiguration = { hostname }:
      nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs username; };
        modules = [
          { nixpkgs.config.allowUnfree = true; }
          inputs.sops-nix.nixosModules.sops
          ./hosts/${hostname}
        ];
      };
  in 
  {
    nixosConfigurations = {
      # All hosts now read their capabilities from hosts/<name>/meta.nix
      # (isGaming, hasNvidia, isHeadless, isLaptop, etc.)

      sb1 = mkNixosConfiguration { hostname = "sb1"; };
      thinkpad = mkNixosConfiguration { hostname = "thinkpad"; };
      macbook = mkNixosConfiguration { hostname = "macbook"; };
      work-intel = mkNixosConfiguration { hostname = "work-intel"; };
      legion = mkNixosConfiguration { hostname = "legion"; };
      desktop = mkNixosConfiguration { hostname = "desktop"; };

      # VM is headless (no GUI, no home-manager)
      vm = mkHeadlessConfiguration { hostname = "vm"; };
    };
    
    # ISO image for desktop installation
    packages.${system} = {
      desktop-iso = (nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs username; };
        modules = [
          stylix.nixosModules.stylix
          inputs.sops-nix.nixosModules.sops
          catppuccin.nixosModules.catppuccin
          ./iso.nix
        ];
      }).config.system.build.isoImage;
    };
  };
}
