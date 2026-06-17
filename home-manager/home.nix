{ config, pkgs, ... }:
{
  home = {
      username = "fuzifuziii";
      homeDirectory = "/home/fuzifuziii";
      stateVersion = "25.11";
    };
  home.pointerCursor = {
    gtk.enable = true;
    x11.enable = true;

    package = pkgs.adwaita-icon-theme;
    name = "Adwaita";
    size = 20;
  };
}

