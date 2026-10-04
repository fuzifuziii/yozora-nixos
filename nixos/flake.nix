{
  description = "fuzi flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-26.05";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    lazyvim.url = "github:pfassina/lazyvim-nix";
    nixcord.url = "github:4evy/nixcord";
    cordial.url = "git+https://github.com/luohoa97/cordial?submodules=1";
    pulsesync-mod = {
      url = "file+https://github.com/PulseSync-LLC/PulseSync-mod/releases/latest/download/app.asar";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, nixpkgs-stable, home-manager, lazyvim, nixcord, cordial, ... }@inputs: 
    let
    system = "x86_64-linux";
    
    pkgs-stable = import nixpkgs-stable {
      inherit system;
      config.allowUnfree = true;
    };
  in {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = { inherit inputs pkgs-stable; };

      modules = [
        ./configuration.nix
	      home-manager.nixosModules.home-manager

        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = { inherit inputs; };
            
          home-manager.users.fuzifuziii = {
            imports = [ 
	            ./home-manager/home.nix
	            lazyvim.homeManagerModules.default
	            nixcord.homeModules.nixcord
	          ];
          };
	      }
      ];
    };
  };
}
