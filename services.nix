{ config, pkgs, lib, fonts, ... }:
{
    services.printing = {
  enable = true;
  browsing = true;
  drivers = with pkgs; [
    gutenprint
  ];
};
  
  services.usbmuxd.enable = true;
  environment.systemPackages = with pkgs; [
    libimobiledevice
    usbutils
    ifuse
  ];

  services.flatpak.enable = true;
  services.earlyoom = {
  enable = true;
  extraArgs = [
    "--avoid" "'^java$'"
  ];
};

  services.avahi = {
    enable = true;
    nssmdns4 = true;  
    publish = {
      enable = true;
      addresses = true;
      workstation = true;
      userServices = true;
    };
  };

  }
