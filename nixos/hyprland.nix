{ config, lib, pkgs, pkgs-stable, inputs, ... }:
{
  environment.systemPackages = with pkgs; [
    # Base
    quickshell
    hyprpicker
    hyprland-preview-share-picker
    quickshell

    # Theme
    kdePackages.breeze
    kdePackages.breeze-icons
    kdePackages.plasma-integration
    kdePackages.qqc2-desktop-style
    kdePackages.systemsettings
    kdePackages.plasma-workspace
    kdePackages.kde-cli-tools
    kdePackages.kio-admin
    kdePackages.flatpak-kcm
    pkgs-stable.tokyonight-gtk-theme

    # Screenshots
    jq
    wayfreeze
    slurp
    grim
    wl-clipboard

    # Other
    pulseaudio
    inotify-tools
    libnotify
    xdg-terminal-exec
    gum
    (python3.withPackages (ps: [
      ps.dbus-fast
    ]))
    gtk3
    cava
  ];

  programs = {
    hyprland.enable = true;
  };

  xdg.portal = {
    enable = true;
    config = {
      common = {
        default = [ "hyprland" "kde" ];
      };
      hyprland = {
        default = [ "hyprland" "kde" ];
        "org.freedesktop.impl.portal.FileChooser" = "kde";
      };
    };
    extraPortals = [
      pkgs.xdg-desktop-portal-hyprland
      pkgs.kdePackages.xdg-desktop-portal-kde
    ];
  };
}
