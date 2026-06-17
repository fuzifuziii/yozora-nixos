{ config, pkgs, lib, ... }:
{
  services.xserver = {
    enable = true;
    desktopManager.xterm.enable = false;
    excludePackages = with pkgs; [
      xterm
    ];
  };

  services.displayManager = {
    sddm.enable = true;
    sddm.wayland.enable = true;
    defaultSession = "hyprland-uwsm";
    };

  services.desktopManager.plasma6.enable = true;
  environment.plasma6.excludePackages = with pkgs; [
  kdePackages.konsole
  kdePackages.okular
  kdePackages.kate
  kdePackages.elisa
  kdePackages.kwallet
  kdePackages.kwallet-pam
  kdePackages.kwalletmanager
  kdePackages.spectacle
  kdePackages.plasma-systemmonitor
  kdePackages.discover
];
  }
