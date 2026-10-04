{ config, lib, pkgs, pkgs-stable, inputs, ... }:
{
  # Packages
  environment.systemPackages = with pkgs; [
    # Base
    kitty
    kdePackages.dolphin
    imv
    mpv

    # Apps
    aseprite
    telegram-desktop
    krita
    kdePackages.kdenlive
    blockbench
    (prismlauncher.override {
    jdks = [ zulu21 zulu25 ];
    })
    qbittorrent
    chromium
    inputs.cordial.packages.${pkgs.system}.default

    (yandex-music.overrideAttrs (old: {
      postInstall = (old.postInstall or "") + ''
      cp ${inputs.pulsesync-mod} $out/share/nodejs/yandex-music.asar
      '';
    }))

    # Archive
    kdePackages.ark
    zip
    unzip
    rar
    unrar
    p7zip

    # Prog
    sqlite
    gcc
    dotnet-sdk
  ];

  programs = {
    dconf.enable = true;
    firefox.enable = true;
    chromium.enable = true;
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

  programs = {
    nix-ld = {
      enable = true;
      libraries = with pkgs; [
        stdenv.cc.cc
        openssl
        nss
        nspr
        glib
        gtk3
        at-spi2-atk
        at-spi2-core
        dbus
        cups
        expat
        libdrm
        libgbm
        mesa
        libxkbcommon
        pango
        cairo
        alsa-lib
        libGL
        libpulseaudio
        libnotify
        libsecret
        systemd
        libx11
        libxcomposite
        libxdamage
        libxext
        libxfixes
        libxrandr
        libxcb
        libxcursor
        libxi
        libxtst
        libxscrnsaver
        libxshmfence
        pipewire
      ];
    };
  };
}
