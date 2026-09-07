{ lib, ... }:
{
  wayland.windowManager.hyprland = {
    enable = true;
    configType = "lua";
    settings = {
      # General
      config = {
        animations = {
          enabled = true;
        };

        cursor = {
          hide_on_key_press = false;
          no_hardware_cursors = true;
          no_warps = false;
        };

        decoration = {
          blur = {
            enabled = false;
          };
          shadow = {
            enabled = false;
          };
          rounding = 0;
        };

        dwindle = {
          force_split = 2;
          preserve_split = true;
        };

        ecosystem = {
          no_update_news = true;
        };

        general = {
          allow_tearing = false;
          border_size = 2;
          col = {
            active_border = {
              colors = [ "rgba(33ccffee)" "rgba(00ff99ee)" ];
              angle = 45;
            };
            inactive_border = "rgba(595959aa)";
          };
          gaps_in = 3;
          gaps_out = 6;
          layout = "dwindle";
          resize_on_border = false;
        };

        input = {
          touchpad = {
            natural_scroll = false;
            scroll_factor = 0.4;
          };
          follow_mouse = 1;
          force_no_accel = true;
          kb_layout = "us,ru";
          kb_options = "grp:alt_shift_toggle";
          numlock_by_default = false;
          repeat_delay = 250;
          repeat_rate = 25;
          sensitivity = 0;
        };

        master = {
          new_status = "master";
        };

        misc = {
          anr_missed_pings = 3;
          disable_hyprland_logo = true;
          disable_splash_rendering = true;
          focus_on_activate = true;
          key_press_enables_dpms = true;
          mouse_move_enables_dpms = true;
          on_focus_under_fullscreen = 1;
        };

        xwayland = {
          force_zero_scaling = true;
        };
      };

      # Other
      monitor = {
        _args = [
          {
            output = "";
            mode = "preferred";
            position = "auto";
            scale = "1";
          }
        ];
      };

      # Env
      env = [
        { _args = [ "SDL_VIDEODRIVER" "wayland" ]; }
        { _args = [ "MOZ_ENABLE_WAYLAND" "1" ]; }
        { _args = [ "ELECTRON_OZONE_PLATFORM_HINT" "auto" ]; }
        { _args = [ "OZONE_PLATFORM" "wayland" ]; }
        { _args = [ "XDG_SESSION_TYPE" "wayland" ]; }

        { _args = [ "XDG_CURRENT_DESKTOP" "Hyprland" ]; }
        { _args = [ "XDG_SESSION_DESKTOP" "Hyprland" ]; }

        { _args = [ "QT_QPA_PLATFORMTHEME" "kde" ]; }
        { _args = [ "QT_QPA_PLATFORM" "wayland;xcb" ]; }
        { _args = [ "XDG_MENU_PREFIX" "plasma-" ]; }
        { _args = [ "SAL_USE_VCLPLUGIN" "kf6" ]; }

        { _args = [ "XCURSOR_SIZE" "20" ]; }
        { _args = [ "HYPRCURSOR_SIZE" "20" ]; }
        { _args = [ "XCURSOR_THEME" "Adwaita" ]; }
        { _args = [ "HYPRCURSOR_THEME" "Adwaita" ]; }

        { _args = [ "GUM_CONFIRM_PROMPT_FOREGROUND" "6;" ]; }
        { _args = [ "GUM_CONFIRM_SELECTED_FOREGROUND" "0;" ]; }
        { _args = [ "GUM_CONFIRM_SELECTED_BACKGROUND" "2;" ]; }
        { _args = [ "GUM_CONFIRM_UNSELECTED_FOREGROUND" "0;" ]; }
        { _args = [ "GUM_CONFIRM_UNSELECTED_BACKGROUND" "8" ]; }

        { _args = [ "NVD_BACKEND" "direct" ]; }
        { _args = [ "LIBVA_DRIVER_NAME" "nvidia" ]; }
        { _args = [ "__GLX_VENDOR_LIBRARY_NAME" "nvidia" ]; }

        { _args = [ "GTK_USE_PORTAL" "1" ]; }
        { _args = [ "TERMINAL" "xdg-terminal-exec" ]; }
        { _args = [ "EDITOR" "nvim" ]; }

        {
          _args = [
            "FUZI_PATH"
            (lib.generators.mkLuaInline ''os.getenv("HOME") .. "/.local/share/fuzi"'')
          ];
        }
        {
          _args = [
            "PATH"
            (lib.generators.mkLuaInline ''(os.getenv("HOME") .. "/.local/share/fuzi") .. "/bin:" .. (os.getenv("HOME") .. "/.local/share/fuzi") .. "/pg:" .. os.getenv("PATH")'')
          ];
        }
      ];

      # Execs
      on = [
        {
          _args = [
            "hyprland.start"
            (lib.generators.mkLuaInline ''
              function()
                -- Session
                hl.exec_cmd("dbus-update-activation-environment --systemd --all")
                hl.exec_cmd("systemctl --user import-environment $(env | cut -d'=' -f 1)")

                -- Yozora
                hl.exec_cmd("quickshell")
                hl.exec_cmd("fuzi-powerprofiles-init")
              end
            '')
          ];
        }
      ];

      # Animations
      curve = [
        {
          _args = [
            "easeOutQuint"
            {
              type = "bezier";
              points = [
                [ 0.23 1 ]
                [ 0.32 1 ]
              ];
            }
          ];
        }
        {
          _args = [
            "easeInOutCubic"
            {
              type = "bezier";
              points = [
                [ 0.65 0.05 ]
                [ 0.36 1 ]
              ];
            }
          ];
        }
        {
          _args = [
            "linear"
            {
              type = "bezier";
              points = [
                [ 0 0 ]
                [ 1 1 ]
              ];
            }
          ];
        }
        {
          _args = [
            "almostLinear"
            {
              type = "bezier";
              points = [
                [ 0.5 0.5 ]
                [ 0.75 1.0 ]
              ];
            }
          ];
        }
        {
          _args = [
            "quick"
            {
              type = "bezier";
              points = [
                [ 0.15 0 ]
                [ 0.1 1 ]
              ];
            }
          ];
        }
      ];

      animation = [
        {
          leaf = "global";
          enabled = true;
          speed = 10;
          bezier = "default";
        }
        {
          leaf = "border";
          enabled = true;
          speed = 5.39;
          bezier = "easeOutQuint";
        }
        {
          leaf = "windows";
          enabled = true;
          speed = 4.79;
          bezier = "easeOutQuint";
        }
        {
          leaf = "windowsIn";
          enabled = true;
          speed = 4.1;
          bezier = "easeOutQuint";
          style = "popin 87%";
        }
        {
          leaf = "windowsOut";
          enabled = true;
          speed = 1.49;
          bezier = "linear";
          style = "popin 87%";
        }
        {
          leaf = "fadeIn";
          enabled = true;
          speed = 1.73;
          bezier = "almostLinear";
        }
        {
          leaf = "fadeOut";
          enabled = true;
          speed = 1.46;
          bezier = "almostLinear";
        }
        {
          leaf = "fade";
          enabled = true;
          speed = 3.03;
          bezier = "quick";
        }
        {
          leaf = "layers";
          enabled = true;
          speed = 3.81;
          bezier = "easeOutQuint";
        }
        {
          leaf = "layersIn";
          enabled = true;
          speed = 4;
          bezier = "easeOutQuint";
          style = "fade";
        }
        {
          leaf = "layersOut";
          enabled = true;
          speed = 1.5;
          bezier = "linear";
          style = "fade";
        }
        {
          leaf = "fadeLayersIn";
          enabled = true;
          speed = 1.79;
          bezier = "almostLinear";
        }
        {
          leaf = "fadeLayersOut";
          enabled = true;
          speed = 1.39;
          bezier = "almostLinear";
        }
        {
          leaf = "workspacesIn";
          enabled = true;
          speed = 3.49;
          bezier = "default";
        }
        {
          leaf = "workspacesOut";
          enabled = true;
          speed = 3.49;
          bezier = "default";
        }
      ];

      # Rules
      layer_rule = [
        {
          match = {
            namespace = "fuzi-notifications";
          };
          no_screen_share = true;
        }
      ];

      window_rule = [
        {
          match = {
            class = "(org.telegram.desktop|AyuGram)";
          };
          no_screen_share = true;
        }
        {
          match = {
            class = "Bitwarden";
          };
          no_screen_share = true;
        }
        {
          match = {
            class = ".*";
          };
          suppress_event = "maximize";
        }
        {
          match = {
            class = "^$";
            title = "^$";
            xwayland = 1;
            float = 1;
            fullscreen = 0;
            pin = 0;
          };
          no_focus = true;
        }
        {
          match = {
            class = "^(1[p|P]assword)$";
          };
          no_screen_share = true;
          tag = "+floating-window";
        }
        {
          match = {
            title = "(Picture.?in.?[Pp]icture)";
          };
          tag = "+pip";
        }
        {
          match = {
            tag = "pip";
          };
          float = true;
          pin = true;
          size = "600 338";
          keep_aspect_ratio = true;
          border_size = 0;
          move = "(monitor_w-window_w-40) (monitor_h*0.04)";
        }
        {
          match = {
            tag = "floating-window";
          };
          float = true;
          center = true;
          size = "875 600";
        }
        {
          match = {
            class = "(org.fuzi.terminal|org.fuzi.bash|org.gnome.NautilusPreviewer|org.gnome.Evince|com.gabm.satty|About|TUI.float|imv|mpv|feh|org.kde.gwenview)";
          };
          tag = "+floating-window";
        }
        {
          match = {
            class = "(xdg-desktop-portal-gtk|xdg-desktop-portal-kde|sublime_text|DesktopEditors|org.gnome.Nautilus|org.kde.dolphin)";
            title = "^(Open.*Files?|Open [F|f]older.*|Save.*Files?|Save.*As|Save|All Files|.*wants to [open|save].*|[C|c]hoose.*)";
          };
          tag = "+floating-window";
        }
        {
          match = {
            class = "org.gnome.Calculator";
          };
          float = true;
        }
        {
          match = {
            tag = "pop";
          };
          rounding = 8;
        }
        {
          match = {
            tag = "noidle";
          };
          idle_inhibit = "always";
        }
        {
          match = {
            class = "(Alacritty|kitty|com.mitchellh.ghostty)";
          };
          tag = "+terminal";
        }
        {
          match = {
            class = "(Alacritty|kitty)";
          };
          scroll_touchpad = 1.5;
        }
        {
          match = {
            class = "com.mitchellh.ghostty";
          };
          scroll_touchpad = 0.2;
        }
      ];

      # Binds
      bind = [
        # Apps
        {
          _args = [
            "SUPER + Return"
            (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("kitty")'')
            { description = "Kitty"; }
          ];
        }
        {
          _args = [
            "SUPER + E"
            (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("dolphin")'')
            { description = "Dolphin"; }
          ];
        }
        {
          _args = [
            "SUPER + W"
            (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("firefox")'')
            { description = "Firefox"; }
          ];
        }
        {
          _args = [
            "SUPER + SHIFT + A"
            (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("steam")'')
            { description = "Steam"; }
          ];
        }
        {
          _args = [
            "SUPER + SHIFT + W"
            (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("Telegram")'')
            { description = "Telegram"; }
          ];
        }
        {
          _args = [
            "SUPER + SHIFT + D"
            (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("discord")'')
            { description = "Discord"; }
          ];
        }
        {
          _args = [
            "SUPER + I"
            (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("systemsettings")'')
            { description = "Settings"; }
          ];
        }

        # Window
        {
          _args = [
            "SUPER + Q"
            (lib.generators.mkLuaInline ''hl.dsp.window.close()'')
          ];
        }
        {
          _args = [
            "SUPER + J"
            (lib.generators.mkLuaInline ''hl.dsp.layout("togglesplit")'')
            { description = "Split"; }
          ];
        }
        {
          _args = [
            "SUPER + T"
            (lib.generators.mkLuaInline ''hl.dsp.window.float({ action = "toggle" })'')
            { description = "Float"; }
          ];
        }
        {
          _args = [
            "SUPER + F"
            (lib.generators.mkLuaInline ''hl.dsp.window.fullscreen({ mode = "fullscreen", action = "toggle" })'')
            { description = "Fullscreen"; }
          ];
        }
        {
          _args = [
            "SUPER + SHIFT + F"
            (lib.generators.mkLuaInline ''hl.dsp.window.fullscreen({ mode = "maximized", action = "toggle" })'')
            { description = "Fullscreen maximized"; }
          ];
        }
        {
          _args = [
            "SUPER + O"
            (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("fuzi-hyprland-window-pop")'')
            { description = "Window pop"; }
          ];
        }

        # Workspace / Focus
        {
          _args = [
            "SUPER + Left"
            (lib.generators.mkLuaInline ''hl.dsp.focus({ direction = "left" })'')
          ];
        }
        {
          _args = [
            "SUPER + Right"
            (lib.generators.mkLuaInline ''hl.dsp.focus({ direction = "right" })'')
          ];
        }
        {
          _args = [
            "SUPER + Up"
            (lib.generators.mkLuaInline ''hl.dsp.focus({ direction = "up" })'')
          ];
        }
        {
          _args = [
            "SUPER + Down"
            (lib.generators.mkLuaInline ''hl.dsp.focus({ direction = "down" })'')
          ];
        }
        {
          _args = [
            "SUPER + code:10"
            (lib.generators.mkLuaInline ''hl.dsp.focus({ workspace = 1 })'')
          ];
        }
        {
          _args = [
            "SUPER + code:11"
            (lib.generators.mkLuaInline ''hl.dsp.focus({ workspace = 2 })'')
          ];
        }
        {
          _args = [
            "SUPER + code:12"
            (lib.generators.mkLuaInline ''hl.dsp.focus({ workspace = 3 })'')
          ];
        }
        {
          _args = [
            "SUPER + code:13"
            (lib.generators.mkLuaInline ''hl.dsp.focus({ workspace = 4 })'')
          ];
        }
        {
          _args = [
            "SUPER + code:14"
            (lib.generators.mkLuaInline ''hl.dsp.focus({ workspace = 5 })'')
          ];
        }
        {
          _args = [
            "SUPER + code:15"
            (lib.generators.mkLuaInline ''hl.dsp.focus({ workspace = 6 })'')
          ];
        }
        {
          _args = [
            "SUPER + code:16"
            (lib.generators.mkLuaInline ''hl.dsp.focus({ workspace = 7 })'')
          ];
        }
        {
          _args = [
            "SUPER + code:17"
            (lib.generators.mkLuaInline ''hl.dsp.focus({ workspace = 8 })'')
          ];
        }
        {
          _args = [
            "SUPER + code:18"
            (lib.generators.mkLuaInline ''hl.dsp.focus({ workspace = 9 })'')
          ];
        }
        {
          _args = [
            "SUPER + code:19"
            (lib.generators.mkLuaInline ''hl.dsp.focus({ workspace = 10 })'')
          ];
        }
        {
          _args = [
            "SUPER + SHIFT + code:10"
            (lib.generators.mkLuaInline ''hl.dsp.window.move({ workspace = 1, follow = false })'')
          ];
        }
        {
          _args = [
            "SUPER + SHIFT + code:11"
            (lib.generators.mkLuaInline ''hl.dsp.window.move({ workspace = 2, follow = false })'')
          ];
        }
        {
          _args = [
            "SUPER + SHIFT + code:12"
            (lib.generators.mkLuaInline ''hl.dsp.window.move({ workspace = 3, follow = false })'')
          ];
        }
        {
          _args = [
            "SUPER + SHIFT + code:13"
            (lib.generators.mkLuaInline ''hl.dsp.window.move({ workspace = 4, follow = false })'')
          ];
        }
        {
          _args = [
            "SUPER + SHIFT + code:14"
            (lib.generators.mkLuaInline ''hl.dsp.window.move({ workspace = 5, follow = false })'')
          ];
        }
        {
          _args = [
            "SUPER + SHIFT + code:15"
            (lib.generators.mkLuaInline ''hl.dsp.window.move({ workspace = 6, follow = false })'')
          ];
        }
        {
          _args = [
            "SUPER + SHIFT + code:16"
            (lib.generators.mkLuaInline ''hl.dsp.window.move({ workspace = 7, follow = false })'')
          ];
        }
        {
          _args = [
            "SUPER + SHIFT + code:17"
            (lib.generators.mkLuaInline ''hl.dsp.window.move({ workspace = 8, follow = false })'')
          ];
        }
        {
          _args = [
            "SUPER + SHIFT + code:18"
            (lib.generators.mkLuaInline ''hl.dsp.window.move({ workspace = 9, follow = false })'')
          ];
        }
        {
          _args = [
            "SUPER + SHIFT + code:19"
            (lib.generators.mkLuaInline ''hl.dsp.window.move({ workspace = 10, follow = false })'')
          ];
        }
        {
          _args = [
            "SUPER + SHIFT + LEFT"
            (lib.generators.mkLuaInline ''hl.dsp.window.swap({ direction = "l" })'')
          ];
        }
        {
          _args = [
            "SUPER + SHIFT + RIGHT"
            (lib.generators.mkLuaInline ''hl.dsp.window.swap({ direction = "r" })'')
          ];
        }
        {
          _args = [
            "SUPER + SHIFT + UP"
            (lib.generators.mkLuaInline ''hl.dsp.window.swap({ direction = "u" })'')
          ];
        }
        {
          _args = [
            "SUPER + SHIFT + DOWN"
            (lib.generators.mkLuaInline ''hl.dsp.window.swap({ direction = "d" })'')
          ];
        }
        {
          _args = [
            "SUPER + Super_L"
            (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("fuzi-menu-app")'')
            { description = "Apps"; }
          ];
        }
        {
          _args = [
            "SUPER + D"
            (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("fuzi-menu toggle")'')
            { description = "Menu"; }
          ];
        }
        {
          _args = [
            "SUPER + K"
            (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("fuzi-menu-binds")'')
            { description = "Binds"; }
          ];
        }
        {
          _args = [
            "SUPER + Period"
            (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("fuzi-shell shell toggle fuzi.emojis")'')
            { description = "Symbols"; }
          ];
        }
        {
          _args = [
            "SUPER + V"
            (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("fuzi-shell shell toggle fuzi.clipboard")'')
            { description = "Clipboard"; }
          ];
        }
        {
          _args = [
            "SUPER + SHIFT + S"
            (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("fuzi-cmd-screenshot smart clipboard")'')
            { description = "Screenshot"; }
          ];
        }
        {
          _args = [
            "SUPER + SHIFT + Q"
            (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("pkill hyprpicker || hyprpicker -a")'')
            { description = "Hyprpicker"; }
          ];
        }

        # Volume / Brightness
        {
          _args = [
            "XF86AudioRaiseVolume"
            (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("fuzi-audio-output-volume +5")'')
            { locked = true; repeating = true; }
          ];
        }
        {
          _args = [
            "XF86AudioLowerVolume"
            (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("fuzi-audio-output-volume -5")'')
            { locked = true; repeating = true; }
          ];
        }
        {
          _args = [
            "XF86AudioMute"
            (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("fuzi-audio-output-volume mute-toggle")'')
            { locked = true; repeating = true; }
          ];
        }
        {
          _args = [
            "XF86AudioMicMute"
            (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("fuzi-audio-input-mute")'')
            { locked = true; repeating = true; }
          ];
        }
        {
          _args = [
            "XF86MonBrightnessUp"
            (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("fuzi-brightness-display +5%")'')
            { locked = true; repeating = true; }
          ];
        }
        {
          _args = [
            "XF86MonBrightnessDown"
            (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("fuzi-brightness-display 5%-")'')
            { locked = true; repeating = true; }
          ];
        }

        # Mouse
        {
          _args = [
            "SUPER + mouse:272"
            (lib.generators.mkLuaInline ''hl.dsp.window.drag()'')
          ];
        }
        {
          _args = [
            "SUPER + mouse:273"
            (lib.generators.mkLuaInline ''hl.dsp.window.resize()'')
          ];
        }
      ];
    };
  };
}

