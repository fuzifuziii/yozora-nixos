{ config, pkgs, lib, ... }:
{
    imports = [
    ./hyprland.nix
    ./exec-once.nix
    ./monitors.nix
    ./settings.nix
    ./binds.nix
    ./windowrules.nix
    ./variables.nix
    ./xdph.nix
    ];
  }
