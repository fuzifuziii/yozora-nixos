{ pkgs, lib, ... }:
{ 
  #Boot
  boot.loader = {
  systemd-boot.enable = true;
  efi.canTouchEfiVariables = true;
  };
  #Kernel
  boot.kernelPackages = pkgs.linuxPackages_zen;
  #boot.kernelPackages = pkgs.linuxPackages_latest;
  #Net
  networking.networkmanager.enable = true;
  networking.firewall.enable = lib.mkForce false;
  #Bluetooth
  hardware.bluetooth = {
  enable = true;
  powerOnBoot = true;
  };
  #Audio
  security.rtkit.enable = true;
  services.pipewire = {
     enable = true;
     pulse.enable = true;
     wireplumber.enable = true;
     jack.enable = true;
     alsa.enable = true;
     alsa.support32Bit = true;
   };
  #Timezone
  time.timeZone = "Europe/Moscow";
}
