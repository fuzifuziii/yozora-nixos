{ config, inputs, pkgs, ... }:
{
  home.pointerCursor = {
    enable = true;
    gtk.enable = true;
    package = pkgs.adwaita-icon-theme;
    name = "Adwaita";
    size = 20;
  };

  gtk = {
    enable = true;
    cursorTheme = {
      package = pkgs.adwaita-icon-theme;
      name = "Adwaita";
      size = 20;
    };
  };

  dconf.settings = {
    "org/gnome/desktop/wm/preferences" = {
      button-layout = ":";
    };
    "org/gnome/desktop/interface" = {
      gtk-theme = "Tokyonight-Dark";
    };
  };

  home.sessionPath = [
    "${config.home.homeDirectory}/.local/share/fuzi/bin"
    "${config.home.homeDirectory}/.local/share/fuzi/pg"
  ];
  home.sessionVariables.FUZI_PATH = "${config.home.homeDirectory}/.local/share/fuzi";
}
