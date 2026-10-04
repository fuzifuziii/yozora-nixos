{ config, lib, pkgs, pkgs-stable, inputs, ... }:
{
  environment.systemPackages = with pkgs; [
    # Base
    quickshell
    hyprpicker
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
    wlr-randr

    # Clipboard
    wl-clipboard
    wl-clip-persist
    cliphist

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
    perl
  ];

  programs = {
    mango.enable = true;
  };

  xdg.portal = {
    enable = true;
    config = {
      mango = {
        default = [ "gtk" ];
        "org.freedesktop.impl.portal.FileChooser" = [ "kde" ];
        "org.freedesktop.impl.portal.ScreenCast" = [ "wlr" ];
        "org.freedesktop.impl.portal.Screenshot" = [ "wlr" ];
      };
    };
    extraPortals = [
      pkgs.xdg-desktop-portal-wlr
      pkgs.kdePackages.xdg-desktop-portal-kde
      pkgs.xdg-desktop-portal-gtk
    ];
  };
}
