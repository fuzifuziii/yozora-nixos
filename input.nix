{
  #Mouse
    services.udev.extraRules = ''
  KERNEL=="hidraw*", ATTRS{idVendor}=="3554", MODE="0666"
'';

  #Ntsync and camera
    boot.kernelModules = [ "ntsync" ];
    boot.blacklistedKernelModules = [ "uvcvideo" ];
  
  #Tablet and gamepad
    hardware.opentabletdriver.enable = true;
    hardware.xone.enable = true;
  }
