{
    services.mako = {
        enable = true;
        settings = {
            include = "~/.config/mako/theme/core.ini";
            text-color = "#c0caf5";
            border-color = "#33ccff";
            background-color = "#1a1b26";
          };
      };
    xdg.configFile."mako/theme/core.ini".text = ''
anchor=top-right
default-timeout=5000
width=420
outer-margin=20
padding=10,15
border-size=2
max-icon-size=32
font=sans-serif 14px
[app-name=Spotify]
invisible=1
[mode=do-not-disturb]
invisible=true
[mode=do-not-disturb app-name=notify-send]
invisible=false
[urgency=critical]
default-timeout=0
layer=overlay
  '';
  }
