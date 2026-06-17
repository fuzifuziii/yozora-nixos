{ config, pkgs, lib, fonts, ... }:
{
    #CPU
    powerManagement = {
      enable = true;
      cpuFreqGovernor = "performance";
      #cpuFreqGovernor = "powersave";
      };
    
    #GPU  
    services.xserver.videoDrivers = [ "nvidia" ];
    hardware = {
      graphics.enable = true;
      graphics.enable32Bit = true;
      nvidia = {
        package = config.boot.kernelPackages.nvidiaPackages.latest;
        open = true;
        modesetting.enable = true;
        powerManagement.enable = true;
        nvidiaSettings = true;
      };
    };
  }
