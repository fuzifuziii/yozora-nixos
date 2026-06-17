{
  wayland.windowManager.hyprland.settings = let
    osdclient = "swayosd-client --monitor eDP-1";
  in {
    bind = [
    "Super, Return, exec, kitty"
    "Super, E, exec, dolphin"
    "Super, W, exec, firefox"
    "Super Shift, A, exec, steam"
    "Super Shift, W, exec, AyuGram"
    "Super Shift, D ,exec, discord"
    "Super Shift, T, exec, fuzi-launch-tui btop"

    "Super, Q, killactive,"
    "Super, J, layoutmsg, togglesplit"
    "Super, T, togglefloating"
    "Super, F, fullscreen, 0"
    "Super Shift, F, fullscreen, 1"
    "Super, O, exec, fuzi-hyprland-window-pop"
    "Super, Left, movefocus, l"
    "Super, Right, movefocus, r"
    "Super, Up, movefocus, u"
    "Super, Down, movefocus, d"
    "Super, code:10, workspace, 1"
    "Super, code:11, workspace, 2"
    "Super, code:12, workspace, 3"
    "Super, code:13, workspace, 4"
    "Super, code:14, workspace, 5"
    "Super, code:15, workspace, 6"
    "Super, code:16, workspace, 7"
    "Super, code:17, workspace, 8"
    "Super, code:18, workspace, 9"
    "Super, code:19, workspace, 10"
    "Super Shift, code:10, movetoworkspacesilent, 1"
    "Super Shift, code:11, movetoworkspacesilent, 2"
    "Super Shift, code:12, movetoworkspacesilent, 3"
    "Super Shift, code:13, movetoworkspacesilent, 4"
    "Super Shift, code:14, movetoworkspacesilent, 5"
    "Super Shift, code:15, movetoworkspacesilent, 6"
    "Super Shift, code:16, movetoworkspacesilent, 7"
    "Super Shift, code:17, movetoworkspacesilent, 8"
    "Super Shift, code:18, movetoworkspacesilent, 9"
    "Super Shift, code:19, movetoworkspacesilent, 10"
    "Super Shift, LEFT, swapwindow, l"
    "Super Shift, RIGHT, swapwindow, r"
    "Super Shift, UP, swapwindow, u"
    "Super Shift, DOWN, swapwindow, d"

    "Super, Super_L, exec, fuzi-launch-walker"
    "Super, Period, exec, fuzi-launch-walker -m symbols"
    "Super, V, exec, fuzi-launch-walker -m clipboard"
    "Super Shift, S, exec, fuzi-cmd-screenshot smart clipboard"
    "Super Shift, Q, exec, pkill hyprpicker || hyprpicker -a"
    ];
    bindm = [
    "Super, mouse:272, movewindow"
    "Super, mouse:273, resizewindow"
    ];
    bindeld = [
    ",XF86AudioRaiseVolume, Volume up, exec, ${osdclient} --output-volume raise"
    ",XF86AudioLowerVolume, Volume down, exec, ${osdclient} --output-volume lower"
    ",XF86AudioMute, Mute, exec, ${osdclient} --output-volume mute-toggle"
    ",XF86AudioMicMute, Mute microphone, exec, ${osdclient} --input-volume mute-toggle"
    ",XF86MonBrightnessUp, Brightness up, exec, ${osdclient} --brightness raise"
    ",XF86MonBrightnessDown, Brightness down, exec, ${osdclient} --brightness lower"
    ];
  };
}
