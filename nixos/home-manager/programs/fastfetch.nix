{
  programs.fastfetch = {
    enable = true;
    settings = {
      logo = {
        padding = {
          left = 2;
          right = 6;
          top = 2;
        };
      };

      modules = [
        "break"
        {
          format = "{#green}┌──────────────────────Hardware──────────────────────┐";
          type = "custom";
        }
        {
          key = " PC";
          keyColor = "green";
          type = "host";
        }
        {
          key = "│ ├";
          keyColor = "green";
          type = "cpu";
          showPeCoreCount = true;
        }
        {
          key = "│ ├";
          keyColor = "green";
          type = "gpu";
          detectionMethod = "pci";
        }
        {
          key = "│ ├󱄄";
          keyColor = "green";
          type = "display";
        }
        {
          key = "│ ├󰋊";
          keyColor = "green";
          type = "disk";
        }
        {
          key = "│ ├";
          keyColor = "green";
          type = "memory";
        }
        {
          key = "│ └󰓡";
          keyColor = "green";
          type = "swap";
        }
        {
          format = "{#green}└────────────────────────────────────────────────────┘";
          type = "custom";
        }
        "break"
        {
          format = "{#blue}┌──────────────────────Software──────────────────────┐";
          type = "custom";
        }
        {
          key = " OS";
          keyColor = "blue";
          type = "os";
        }
        {
          key = "│ ├󰔫";
          keyColor = "blue";
          text = "echo \"Yozora\"";
          type = "command";
        }
        {
          key = "│ ├♥";
          keyColor = "blue";
          text = "echo \"by fuzifuziii\"";
          type = "command";
        }
        {
          key = "│ ├𐐃";
          keyColor = "blue";
          type = "kernel";
        }
        {
          key = "│ ├";
          keyColor = "blue";
          type = "wm";
        }
        {
          key = "│ ├";
          keyColor = "blue";
          type = "terminal";
        }
        {
          key = "│ └󰏖";
          keyColor = "blue";
          type = "packages";
        }
        {
          format = "{#blue}└────────────────────────────────────────────────────┘";
          type = "custom";
        }
        "break"
        {
          format = "{#magenta}┌────────────────────Age & Uptime────────────────────┐";
          type = "custom";
        }
        {
          key = "󱦟 OS Age";
          keyColor = "magenta";
          text = "echo $(( ($(date +%s) - $(stat -c %W /)) / 86400 )) days";
          type = "command";
        }
        {
          key = "󱫐 Uptime";
          keyColor = "magenta";
          type = "uptime";
        }
        {
          format = "{#magenta}└────────────────────────────────────────────────────┘";
          type = "custom";
        }
        "break"
      ];
    };
  };
}
