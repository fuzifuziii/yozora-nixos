{ config, lib, pkgs, pkgs-stable, inputs, ... }:

{
  imports =
    [ 
      ./hardware-configuration.nix
      ./system.nix
      ./nvidia.nix
      ./services.nix
      ./programs.nix
      ./hyprland.nix
    ];
    
  nixpkgs.config.allowUnfree = true;
  hardware.enableRedistributableFirmware = true;

  nix.settings = {
    #access-tokens = [ "" ];
    experimental-features = [ "nix-command" "flakes" ];
  };
  
  system.stateVersion = "26.05";
}
