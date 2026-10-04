{ inputs, pkgs, ... }:
{
  imports = [
    ./theme.nix
    ./programs.nix

    ./programs/fastfetch.nix
    ./programs/kitty.nix
    ./programs/fish.nix

    ./mango.nix
    ./quickshell.nix
  ];

  home.username = "fuzifuziii";
  home.homeDirectory = "/home/fuzifuziii";

  home.stateVersion = "26.05"; 
}
