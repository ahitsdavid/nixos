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
    zen-browser.url = "github:0xc000022070/zen-browser-flake";
    sops-nix.url = "github:Mic92/sops-nix";
    stylix.url = "github:danth/stylix";
  };

  outputs = { 
    self, 
    nixpkgs, 
    home-manager,
    nurpkgs,
    ... 
    } @ inputs: 
  let 
    system = "x86_64-linux";
    username = "davidthach";
    
  in 
  {
    nixosConfigurations = {
      #SB Configuration
      sb1 = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs username; };
        modules = [
          # Host configuration
          ./hosts/sb1

          # NUR Overlay
          { nixpkgs.overlays = [ nurpkgs.overlays.default ]; }

          # GDM Profile Picture Module
          ./home/modules/gdm.nix
          
          # Enable and configure the GDM face module
          {
            services.gdm-face = {
              enable = true;
              session = "hyprland"; # Default Session for user
            };
          }

          # home-manager NixOS module
          home-manager.nixosModules.home-manager {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = { inherit inputs username system; };
            home-manager.users.${username} = { imports = [
              ./home/base.nix
              #./home/work.nix
              ./home/gaming.nix
            ]; };
          }
        ];
      };
      #Thinkpad Configuration
      thinkpad = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs username; };
        modules = [
          # Host configuration
          ./hosts/thinkpad

          # NUR Overlay
          { nixpkgs.overlays = [ nurpkgs.overlays.default ]; }
          
          # GDM Profile Picture Module
          ./home/modules/gdm.nix
          
          # Enable and configure the GDM face module
          {
            services.gdm-face = {
              enable = true;
              session = "hyprland"; # Default Session for user
            };
          }
          
          # home-manager NixOS module
          home-manager.nixosModules.home-manager {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = { inherit inputs username system; };
            home-manager.users.${username} = { 
              imports = [
                ./home/base.nix
                ./home/gaming.nix
              ];
            };
          }
        ];
      };
      #VM Configuration
      vm = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs username; };
        modules = [
          # Host configuration
          ./hosts/vm

          # NUR Overlay
          { nixpkgs.overlays = [ nurpkgs.overlays.default ]; }

          # GDM Profile Picture Module
          ./home/modules/gdm.nix
          
          # Enable and configure the GDM face module
          {
            services.gdm-face = {
              enable = true;
              session = "hyprland"; # Default Session for user
            };
          }

          # home-manager NixOS module
          home-manager.nixosModules.home-manager {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.backupFileExtension = "backup";
            home-manager.extraSpecialArgs = { inherit inputs username system; };
            home-manager.users.${username} = { imports = [
              ./home/base.nix
              #./home/work.nix
              ./home/gaming.nix
            ]; };
          }
        ];
      };
    };    
  };
}
