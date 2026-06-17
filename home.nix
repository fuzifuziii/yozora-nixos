{ config, pkgs, lib, ... }:
{
	imports = [
          ./home-manager/home.nix

          ./home-manager/hyprland/default.nix
          ./home-manager/waybar.nix

          ./home-manager/nvim.nix
          ./home-manager/kitty.nix
          ./home-manager/fish.nix
          ./home-manager/mako.nix
          ./home-manager/fastfetch.nix
          ./home-manager/btop.nix
          ./home-manager/swayosd.nix
          ./home-manager/uwsm.nix
          ./home-manager/walker.nix
          ./home-manager/elephant.nix
          ./home-manager/playit.nix
      ];
}
