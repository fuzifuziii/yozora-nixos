{ config, lib, pkgs, pkgs-stable, inputs, ... }:
{
  # Packages
  environment.systemPackages = with pkgs; [
    # Base
    kitty
    kdePackages.dolphin
    feh
    mpv

    # Apps
    aseprite
    telegram-desktop
    krita
    kdePackages.kdenlive
    blockbench
    (prismlauncher.override {
    jdks = [ zulu21 ];
    })
    onlyoffice-desktopeditors

    # Archive
    kdePackages.ark
    zip
    unzip
    rar
    unrar
    p7zip
  ];

  programs = {
    firefox.enable = true;
    fish.enable = true;
    git.enable = true;

    steam = {
      enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
    };

    throne = {
      enable = true;
      tunMode.enable = true;
    };

    obs-studio = {
      enable = true;
      package = (pkgs.obs-studio.override { 
        cudaSupport = true; 
      });
      plugins = with pkgs.obs-studio-plugins; [ 
        obs-pipewire-audio-capture 
      ];
    };

    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
  };

  # Remove
  environment.defaultPackages = [ ];
  programs = {
    nano.enable = false;
  };

  fonts.packages = with pkgs; [
    corefonts
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif
    noto-fonts-color-emoji
    nerd-fonts.jetbrains-mono
  ];
}
