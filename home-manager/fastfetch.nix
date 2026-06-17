{
    programs.fastfetch = {
        enable = true;
        settings = {
  logo = {
    type = "kitty";
    source = "/home/fuzifuziii/Pictures/.g/g.jpg";
    color = { "1" = "green"; };
    width = 35;
    height = 16;
    padding = {
      top = 2;
      right = 6;
      left = 2;
    };
  };
  modules = [
    "break"
    {
      type = "custom";
      format = "{#green}┌──────────────────────Hardware──────────────────────┐";
    }
    {
      type = "host";
      key = " PC";
      keyColor = "green";
    }
    {
      type = "cpu";
      key = "│ ├";
      showPeCoreCount = true;
      keyColor = "green";
    }
    {
      type = "gpu";
      key = "│ ├";
      detectionMethod = "pci";
      keyColor = "green";
    }
    {
      type = "display";
      key = "│ ├󱄄";
      keyColor = "green";
    }
    {
      type = "disk";
      key = "│ ├󰋊";
      keyColor = "green";
    }
    {
      type = "memory";
      key = "│ ├";
      keyColor = "green";
    }
    {
      type = "swap";
      key = "└ └󰓡";
      keyColor = "green";
    }
    {
      type = "custom";
      format = "{#green}└────────────────────────────────────────────────────┘";
    }
    "break"
    {
      type = "custom";
      format = "{#blue}┌──────────────────────Software──────────────────────┐";
    }
    {
      type = "os";
      key = " OS";
      keyColor = "blue";
    }
    {
      type = "command";
      key = "│ ├󰔫";
      keyColor = "blue";
      text = "echo \"fuzi-dotfiles 1.7\"";
    }
    {
      type = "command";
      key = "│ ├♥";
      keyColor = "blue";
      text = "echo \"by fuzifuziii\"";
    }
    {
      type = "kernel";
      key = "│ ├𐐃";
      keyColor = "blue";
    }
    {
      type = "wm";
      key = "│ ├";
      keyColor = "blue";
    }
    {
      type = "de";
      key = " DE";
      keyColor = "blue";
    }
    {
      type = "terminal";
      key = "│ ├";
      keyColor = "blue";
    }
    {
      type = "packages";
      key = "│ ├󰏖";
      keyColor = "blue";
    }
    {
      type = "wmtheme";
      key = "│ ├󰉼";
      keyColor = "blue";
    }
    {
      type = "terminalfont";
      key = "└ └";
      keyColor = "blue";
    }
    {
      type = "custom";
      format = "{#blue}└────────────────────────────────────────────────────┘";
    }
    "break"
    {
      type = "custom";
      format = "{#magenta}┌────────────────────Age & Uptime────────────────────┐";
    }
    {
      type = "command";
      key = "󱦟 OS Age";
      keyColor = "magenta";
      text = "echo $(( ($(date +%s) - $(stat -c %W /)) / 86400 )) days";
    }
    {
      type = "uptime";
      key = "󱫐 Uptime";
      keyColor = "magenta";
    }
    {
      type = "custom";
      format = "{#magenta}└────────────────────────────────────────────────────┘";
    }
    "break"
  ];
};
          };
  }
