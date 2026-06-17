{
  wayland.windowManager.hyprland.settings = let
    activeBorderColor = "rgba(33ccffee) rgba(00ff99ee) 45deg";
    inactiveBorderColor = "rgba(595959aa)";
  in {
    input = {
      kb_layout = "us,ru";
      kb_options = "grp:alt_shift_toggle";

      repeat_rate = 25;
      repeat_delay = 250;

      numlock_by_default = false;
      force_no_accel = true;
      sensitivity = 0;
      follow_mouse = 1;

      touchpad = {
        scroll_factor = 0.4;
        natural_scroll = false;
      };
    };

    activeBorderColor = "rgba(33ccffee) rgba(00ff99ee) 45deg";
    inactiveBorderColor = "rgba(595959aa)";

    general = {
      layout = "dwindle";
      gaps_in = 3;
      gaps_out = 6;
      border_size = 2;

      "col.active_border" = activeBorderColor;
      "col.inactive_border" = inactiveBorderColor;

      resize_on_border = false;
      allow_tearing = false;
    };

    misc = {
      disable_hyprland_logo = true;
      disable_splash_rendering = true;
      focus_on_activate = true;
      anr_missed_pings = 3;
      on_focus_under_fullscreen = 1;
      key_press_enables_dpms = true;
      mouse_move_enables_dpms = true;
    };

    dwindle = {
      force_split = 2;
      preserve_split = true;
    };

    master = {
      new_status = "master";
    };

    decoration = {
      rounding = 0;

      blur = {
        enabled = false;
      };

      shadow = {
        enabled = false;
      };
    };

    animations = {
      enabled = true;

      bezier = [
        "easeOutQuint, 0.23,1, 0.32,1"
        "easeInOutCubic, 0.65, 0.05, 0.36,1"
        "linear, 0, 0, 1, 1"
        "almostLinear,0.5, 0.5, 0.75, 1.0"
        "quick, 0.15, 0, 0.1, 1"
      ];

      animation = [
        "global, 1, 10, default"
        "border, 1, 5.39, easeOutQuint"
        "windows, 1, 4.79, easeOutQuint"
        "windowsIn, 1, 4.1, easeOutQuint, popin 87%"
        "windowsOut, 1, 1.49, linear, popin 87%"
        "fadeIn, 1, 1.73, almostLinear"
        "fadeOut, 1, 1.46, almostLinear"
        "fade, 1, 3.03, quick"
        "layers, 1, 3.81, easeOutQuint"
        "layersIn, 1, 4, easeOutQuint, fade"
        "layersOut, 1, 1.5, linear, fade"
        "fadeLayersIn, 1, 1.79, almostLinear"
        "fadeLayersOut, 1, 1.39, almostLinear"
        "workspacesIn, 1, 3.49, default"
        "workspacesOut, 1, 3.49, default"
      ];
    };
    
    cursor = {
        hide_on_key_press = false;
        no_warps = false;
        no_hardware_cursors = true;
      };

    xwayland = {
      force_zero_scaling = true;
    };
    ecosystem = {
        no_update_news = true;
      };
    device = {
        name = "msnb0001:00-04f3:30aa-touchpad";
        #enabled = false;
        enabled = true;
      };
    plugin = {
    csgo-vulkan-fix = {
        fix_mouse = true;
        # Add apps with vkfix-app = initialClass, width, height
    };
  };
  };
}
