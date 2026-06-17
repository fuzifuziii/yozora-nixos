{ config, pkgs, lib, ... }:

{
  imports = [
      ./default.nix
    ];
  
  disabledModules = [ "services/misc/elephant.nix" ];

  #Github token
  nix = {
    extraOptions = ''
      access-tokens = 
    '';
  };

  #Nix functions
  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  #User
  networking.hostName = "nixos";
   users.users.fuzifuziii = {
     isNormalUser = true;
     extraGroups = [ "wheel" "input" ];
   };

  #Language
   i18n.defaultLocale = "en_US.UTF-8";
   i18n.extraLocales = [ "en_US.UTF-8/UTF-8" "en_GB.UTF-8/UTF-8" "ru_RU.UTF-8/UTF-8" ];
   i18n.extraLocaleSettings = {
     LC_TIME = "en_GB.UTF-8";
   };

  system.stateVersion = "25.11";

}

