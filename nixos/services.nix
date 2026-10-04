{ config, lib, pkgs, pkgs-stable, inputs, ... }:
{
  services = {
    dbus.enable = true;
    thermald.enable = true;
    openssh.enable = true;
    gvfs.enable = true;

    # Optimization
    ananicy = {
      enable = true;
      package = pkgs.ananicy-cpp;
      rulesProvider = pkgs.ananicy-rules-cachyos;
    };
    psd.enable = true;

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
