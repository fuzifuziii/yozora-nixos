{ inputs, pkgs, ... }:
{
  imports = [
    ./theme.nix
    ./programs.nix

    ./programs/fastfetch.nix
    ./programs/kitty.nix
    ./programs/fish.nix

    ./quickshell.nix
    ./hyprland/settings.nix
    ./hyprland/xdph.nix
    ./hyprland/picker.nix
  ];

  home.username = "fuzifuziii";
  home.homeDirectory = "/home/fuzifuziii";

  home.stateVersion = "26.05"; 
}
