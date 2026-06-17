{
  description = "fuzi flake";

  nixConfig = {
    extra-substituters = [ "https://playit-nixos-module.cachix.org" ];
    extra-trusted-public-keys = [ "playit-nixos-module.cachix.org-1:22hBXWXBbd/7o1cOnh+p0hpFUVk9lPdRLX3p5YSfRz4=" ];
  }; 
  
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    walker.url = "github:abenz1267/walker";
    playit-nixos-module.url = "github:pedorich-n/playit-nixos-module";
    spicetify-nix.url = "github:Gerg-L/spicetify-nix";
    lazyvim.url = "github:pfassina/lazyvim-nix";
    nixcord.url = "github:FlameFlag/nixcord";
  };

  outputs = { self, nixpkgs, walker, playit-nixos-module, home-manager, spicetify-nix, lazyvim, nixcord, ... }:
  let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
    spicePkgs = spicetify-nix.legacyPackages.${system};
  in
  {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      inherit system;

      modules = [
        walker.nixosModules.default
        playit-nixos-module.nixosModules.default
        spicetify-nix.nixosModules.default
        home-manager.nixosModules.home-manager
        nixcord.nixosModules.nixcord

        ./configuration.nix

         {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;

          home-manager.users.fuzifuziii = import ./home.nix;
	        home-manager.extraSpecialArgs = { inherit lazyvim; };
        }

        {
          programs.walker.enable = true;
          services.playit = {
              enable = true;
              secretPath = "/home/fuzifuziii/.config/playit_gg/playit.toml";
          };
          programs.spicetify = {
            enable = true;
            enabledExtensions = with spicePkgs.extensions; [
              adblockify
              hidePodcasts
            ];
            enabledCustomApps = with spicePkgs.apps; [
              marketplace
            ];
            theme = {
              name = "Tokyo-Night"; # Имя папки внутри репозитория
              src = pkgs.fetchFromGitHub {
                owner = "evening-hs";
                repo = "Spotify-Tokyo-Night-Theme";
                rev = "main";
                hash = "sha256-cLj9v8qtHsdV9FfzV2Qf4pWO8AOBXu51U/lUMvdEXAk="; 
              };
              injectCss = true;
              replaceColors = true;
              overwriteAssets = true;
            };
            colorScheme = "Night";
          };
        }
      ];
    };
  };
}
