{ config, pkgs, lib, ... }:
{
  home.packages = with pkgs; [
  wl-clipboard
  wl-clip-persist
  polkit_gnome

  hyprpicker
  swayosd
  swaybg
  tokyonight-gtk-theme

  wiremix
  pamixer
  bluez
  bluetui
  playerctl
  pulseaudio

  xdg-desktop-portal-gtk
  xdg-desktop-portal-hyprland

  jq
  wayfreeze
  grim
  slurp
  satty
  ];

    xdg.portal = {
  enable = true;
  config = {
    hyprland.preferred = [ "hyprland" "gtk" ];
    niri.preferred = [ "hyprland" "gtk" ];
  };
};

    xdg.terminal-exec = {
  enable = true;
  settings = {
    default = [ "kitty.desktop" ];
  };
};
    
  wayland.windowManager.hyprland = {
    enable = true;
    configType = "hyprlang";
    xwayland = {
      enable = true;
    };
    systemd.enable = false;
  };
}
