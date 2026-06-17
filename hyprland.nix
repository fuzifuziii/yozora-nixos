{ config, pkgs, lib, inputs, ... }:
{
    programs = {
      hyprland.enable = true;
      hyprland.xwayland.enable = true;
      hyprland.withUWSM = true;
      #hyprlock.enable = true;
      };

    #services.hypridle.enable = true;

    programs.uwsm = {
        enable = true;
        waylandCompositors = {
    hyprland = {
      prettyName = "Hyrpland";
      comment = "Hyprland compositor managed by UWSM";
      binPath = "/run/current-system/sw/bin/start-hyprland";
    };
  };
};

    xdg.portal = {
  enable = true;
  config = {
    common.default = [ "hyprland" "gtk" ];
    hyprland.default = [ "hyprland" "gtk" ];
  };
};

    xdg.terminal-exec = {
  enable = true;
  settings = {
    default = [ "kitty.desktop" ];
  };
};
    
    security.polkit.enable = true;

    environment.systemPackages = with pkgs; [
      kdePackages.polkit-kde-agent-1
    ];

    systemd.user.services.polkit-gnome-authentication-agent-1 = {
    description = "polkit-gnome-authentication-agent-1";
    wantedBy = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    serviceConfig.Type = "simple";
    serviceConfig.ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
    serviceConfig.Restart = "on-failure";
    };
  }
