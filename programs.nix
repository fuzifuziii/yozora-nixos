{ config, pkgs, lib, fonts, ... }:
{
  programs.nano.enable = false;
  programs.firefox.enable = true;
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
  };
  programs.gamemode.enable = true;
  programs.zoom-us.enable = true;
  programs.amnezia-vpn.enable = true;

  programs.throne = {
      enable = true;
      tunMode.enable = true;
    };

  programs.obs-studio = {
      enable = true;
      package = pkgs.obs-studio.override {
        cudaSupport = true;
      };
      plugins = with pkgs.obs-studio-plugins; [
          obs-pipewire-audio-capture
      ];
    };
  programs.nix-ld.enable = true;
    programs.nix-ld.libraries = with pkgs; [
      gtk4-layer-shell
      gtk4
      glib
      cairo
      pango
      gdk-pixbuf
      atk
      harfbuzz
  ];
  
  environment.systemPackages = with pkgs; [
    libreoffice-fresh
     adwaita-icon-theme
     mpv
     nwg-look
     kdePackages.dolphin
     kdePackages.systemsettings
     kdePackages.ark
     kdePackages.knewstuff
     ayugram-desktop
     prismlauncher
     blockbench
     kdePackages.kdenlive
     chromium
     obsidian
     dconf-editor
     rpiplay
     protonup-qt
     (python3.withPackages (ps: with ps; [
    pyqt6
    pip
  ]))
     sherlock
     upscayl
     aseprite
     bitwarden-desktop
     osu-lazer-bin
     mcaselector
     krita
   ];

   nixpkgs.config.permittedInsecurePackages = [
    "electron-39.8.10"
    ];

  }
