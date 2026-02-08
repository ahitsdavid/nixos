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

    # Import host builder functions from lib
    builders = import ./lib/host-builders.nix {
      inherit nixpkgs inputs system username nurpkgs catppuccin stylix home-manager;
    };
    inherit (builders) mkNixosConfiguration mkHeadlessConfiguration;
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
    packages.${system} = let
      pkgs = import nixpkgs { inherit system; };
    in {
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

      # Build all system closures (for populating the Harmonia binary cache)
      all-systems = pkgs.linkFarm "all-systems" (
        builtins.map (name: {
          inherit name;
          path = self.nixosConfigurations.${name}.config.system.build.toplevel;
        }) [ "desktop" "thinkpad" "legion" "work-intel" "sb1" "macbook" ]
      );
    };

    # Development shell with linting tools
    devShells.${system}.default = let
      pkgs = import nixpkgs { inherit system; };
    in pkgs.mkShell {
      packages = with pkgs; [
        statix      # Nix linter
        deadnix     # Dead code finder
        nixfmt-rfc-style  # Nix formatter
      ];
    };
  };
}
