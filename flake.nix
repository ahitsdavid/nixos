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

    nurpkgs.url = "github:nix-community/NUR";
    nvf = {
      url = "github:notashelf/nvf";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprland = {
        type = "git";
        url = "https://github.com/hyprwm/Hyprland";
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
    quickshell = {
      url = "git+https://git.outfoxxed.me/outfoxxed/quickshell";
      inputs.nixpkgs.follows = "nixpkgs";
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
    #zen-browser.url = "github:0xc000022070/zen-browser-flake";
    sops-nix.url = "github:Mic92/sops-nix";
  };

  outputs = { 
    self, 
    nixpkgs, 
    home-manager,
    nurpkgs,
    catppuccin,
    quickshell,
    ... 
    } @ inputs: 
  let 
    system = "x86_64-linux";
    username = "davidthach";
    
    # Create a function to make a NixOS configuration with common modules
    mkNixosConfiguration = { hostname, extraModules ? [] }: 
      nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs username; };
        modules = [
          # Host-specific configuration
          ./hosts/${hostname}

          # Catpuccin theming
          catppuccin.nixosModules.catppuccin
          # NUR Overlay
          { nixpkgs.overlays = [ nurpkgs.overlays.default ]; }

          # home-manager NixOS module
          home-manager.nixosModules.home-manager {
            home-manager.useGlobalPkgs = true;
            home-manager.backupFileExtension = "backup";
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = { inherit inputs username system quickshell; };
            home-manager.users.${username} = { 
              imports = [
                ./home/base.nix
                ./home/gaming.nix
                # Add any extra home-manager modules
              ] ++ (extraModules.homeModules or []);
            };
          }
        ] ++ (extraModules.systemModules or []);
      };
  in 
  {
    nixosConfigurations = {
      # SB Configuration
      sb1 = mkNixosConfiguration {
        hostname = "sb1";
        # If you need specific modules for this host:
        # extraModules.homeModules = [ ./home/work.nix ];
      };
      
      # Thinkpad Configuration
      thinkpad = mkNixosConfiguration {
        hostname = "thinkpad";
        extraModules.homeModules = [ catppuccin.homeModules.catppuccin ];
      };
      
      # VM Configuration
      vm = mkNixosConfiguration {
        hostname = "vm";
        extraModules.systemModules = [
          # VM-specific system modules
          { home-manager.backupFileExtension = "backup"; }
        ];
        # If you need VM-specific home modules:
        # extraModules.homeModules = [ ./home/vm-specific.nix ];
      };
    };    
  };
}
