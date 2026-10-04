{ config, lib, pkgs, pkgs-stable, inputs, ... }:
{
  # User
  users.users.fuzifuziii = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    shell = pkgs.fish;
  };

  security.sudo.extraRules = [
    {
      users = [ "fuzifuziii" ];
      commands = [
        {
          command = "${pkgs.profile-sync-daemon}/bin/psd-overlay-helper";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];

  boot = {
    kernel.sysctl."vm.max_map_count" = 2147483642;
    #kernelPackages = pkgs.linuxPackages_latest;
    kernelPackages = pkgs.linuxPackages_zen;
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
  };
  time.timeZone = "Europe/Moscow";

  # Network
  networking = {
    hostName = "nixos";
    firewall.enable = false;
    networkmanager = {
      enable = true;
      wifi.powersave = false;
    };
  };

  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 50;
  };

  hardware = {
    xone.enable = true;
    bluetooth = {
      enable = true;
      powerOnBoot = false;
    };
  };

  # Language
  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
      LC_TIME = "en_GB.UTF-8";
    };
  };

  # Sound
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };

  # udev
  services.udev.extraRules = ''
    SUBSYSTEM=="usb", ATTRS{idVendor}=="3554", MODE="0666"
    SUBSYSTEM=="hidraw", ATTRS{idVendor}=="3554", MODE="0666"
  '';
}
