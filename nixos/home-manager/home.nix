{ inputs, pkgs, ... }:
{
  imports = [
    ./theme.nix
    ./programs.nix

    ./fastfetch.nix
    ./kitty.nix
    ./fish.nix

    ./quickshell.nix
    ./hyprland/settings.nix
    ./hyprland/xdph.nix
    ./picker.nix
  ];

  home.username = "fuzifuziii";
  home.homeDirectory = "/home/fuzifuziii";

  home.stateVersion = "26.05"; 
}
