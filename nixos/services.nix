{ config, lib, pkgs, pkgs-stable, inputs, ... }:
{
  services = {
    dbus.enable = true;
    openssh.enable = true;
    flatpak.enable = true;

    # Battery
    upower.enable = true;
    power-profiles-daemon.enable = true;

    displayManager.ly = {
      enable = true;
      settings = {
        session_log = "/dev/null";
      };
    };

    xserver = {
      enable = true;
      excludePackages = [ pkgs.xterm ];
      videoDrivers = [ "nvidia" ];
    };

    # Cups
    printing = {
      enable = true;
      drivers = [ 
        pkgs.gutenprint 
        pkgs.ghostscript
      ];
    };
  };
}
