{
xdg.configFile."mango/config.conf".text = ''
  # Animations
  animations=1
  layer_animations=1
  animation_type_open=zoom
  animation_type_close=fade
  layer_animation_type_open=fade
  layer_animation_type_close=fade
  animation_fade_in=1
  animation_fade_out=1
  # popin 87%
  zoom_initial_ratio=0.87
  animation_duration_move=450
  animation_duration_open=410
  animation_duration_tag=350
  animation_duration_close=150
  # easeOutQuint
  animation_curve_open=0.23,1,0.32,1
  animation_curve_move=0.23,1,0.32,1
  animation_curve_tag=0.23,1,0.32,1
  animation_curve_close=0,0,1,1

  # Window
  borderpx=2
  border_radius=0
  blur=0
  shadows=0
  gappih=3
  gappiv=3
  gappoh=6
  gappov=6

  bordercolor=0x595959aa
  focuscolor=0x33ccffee
  dropcolor=0x33ccffee
  maximizescreencolor=0x33ccffee
  cursor_size=20
  cursor_theme=Adwaita

  # Layout
  tag_num=10
  tagrule=id:*,layout_name:dwindle
  circle_layout=dwindle,scroller,tile
  dwindle_preserve_split=1

  dwindle_hsplit=1
  dwindle_vsplit=1

  # Input
  xkb_rules_layout=us,ru
  xkb_rules_options=grp:alt_shift_toggle
  repeat_delay=250
  repeat_rate=25
  numlockon=0

  mouse_accel_profile=1
  mouse_accel_speed=0
  mouse_natural_scrolling=0
  trackpad_natural_scrolling=0
  trackpad_scroll_factor=0.4

  auto_reload_config=1

  # Environment
  env=SDL_VIDEODRIVER,wayland
  env=MOZ_ENABLE_WAYLAND,1
  env=ELECTRON_OZONE_PLATFORM_HINT,auto
  env=OZONE_PLATFORM,wayland
  env=XDG_SESSION_TYPE,wayland
  env=XDG_CURRENT_DESKTOP,mango
  env=XDG_SESSION_DESKTOP,mango
  env=QT_QPA_PLATFORMTHEME,kde
  env=QT_QPA_PLATFORM,wayland;xcb
  env=XDG_MENU_PREFIX,plasma-
  env=SAL_USE_VCLPLUGIN,kf6
  env=XCURSOR_SIZE,20
  env=XCURSOR_THEME,Adwaita
  env=NVD_BACKEND,direct
  env=LIBVA_DRIVER_NAME,nvidia
  env=__GLX_VENDOR_LIBRARY_NAME,nvidia
  env=GTK_USE_PORTAL,1
  env=TERMINAL,xdg-terminal-exec
  env=EDITOR,nvim

  # Autostart
  exec-once = dbus-update-activation-environment --systemd --all
  exec-once = systemctl --user import-environment ''$(env | cut -d'=' -f 1)
  exec-once = wl-clip-persist --clipboard regular --reconnect-tries 0

  exec-once = quickshell
  exec-once = fuzi-powerprofiles-init

  # Apps
  bind=SUPER,Return,spawn,kitty
  bind=SUPER,e,spawn,dolphin
  bind=SUPER,w,spawn,firefox
  bind=SUPER+SHIFT,a,spawn,steam
  bind=SUPER+SHIFT,w,spawn,Telegram
  bind=SUPER+SHIFT,d,spawn,discord
  bind=SUPER,i,spawn,systemsettings

  # Window
  bind=SUPER,q,killclient,
  bind=SUPER,j,switch_layout
  bind=SUPER,t,togglefloating,
  bind=SUPER,f,togglefullscreen,
  bind=SUPER+SHIFT,f,togglemaximizescreen,

  # Focus
  bind=SUPER,Left,focusdir,left
  bind=SUPER,Right,focusdir,right
  bind=SUPER,Up,focusdir,up
  bind=SUPER,Down,focusdir,down
  bind=SUPER+SHIFT,Left,exchange_client,left
  bind=SUPER+SHIFT,Right,exchange_client,right
  bind=SUPER+SHIFT,Up,exchange_client,up
  bind=SUPER+SHIFT,Down,exchange_client,down

  # Tags
  bind=SUPER,code:10,view,1
  bind=SUPER,code:11,view,2
  bind=SUPER,code:12,view,3
  bind=SUPER,code:13,view,4
  bind=SUPER,code:14,view,5
  bind=SUPER,code:15,view,6
  bind=SUPER,code:16,view,7
  bind=SUPER,code:17,view,8
  bind=SUPER,code:18,view,9
  bind=SUPER,code:19,view,10

  bind=SUPER+SHIFT,code:10,tagsilent,1
  bind=SUPER+SHIFT,code:11,tagsilent,2
  bind=SUPER+SHIFT,code:12,tagsilent,3
  bind=SUPER+SHIFT,code:13,tagsilent,4
  bind=SUPER+SHIFT,code:14,tagsilent,5
  bind=SUPER+SHIFT,code:15,tagsilent,6
  bind=SUPER+SHIFT,code:16,tagsilent,7
  bind=SUPER+SHIFT,code:17,tagsilent,8
  bind=SUPER+SHIFT,code:18,tagsilent,9
  bind=SUPER+SHIFT,code:19,tagsilent,10

  # Shell
  bindr = SUPER,Super_L,spawn,fuzi-menu-app mango
  bind=SUPER,d,spawn,fuzi-menu toggle
  bind=SUPER,k,spawn,fuzi-menu-binds
  bind=SUPER,period,spawn,fuzi-shell shell toggle fuzi.emojis
  bind=SUPER,v,spawn,fuzi-shell shell toggle fuzi.clipboard
  bind=SUPER+SHIFT,s,spawn,fuzi-cmd-screenshot smart clipboard
  bind=SUPER+SHIFT,q,spawn_shell,pkill hyprpicker || hyprpicker -a

  # Media
  bindl=NONE,XF86AudioRaiseVolume,spawn,fuzi-audio-output-volume +5
  bindl=NONE,XF86AudioLowerVolume,spawn,fuzi-audio-output-volume -5
  bindl=NONE,XF86AudioMute,spawn,fuzi-audio-output-volume mute-toggle
  bindl=NONE,XF86AudioMicMute,spawn,fuzi-audio-input-mute
  bindl=NONE,XF86MonBrightnessUp,spawn,fuzi-brightness-display +5%
  bindl=NONE,XF86MonBrightnessDown,spawn,fuzi-brightness-display 5%-

  # Mouse
  mousebind=SUPER,btn_left,moveresize,curmove
  mousebind=SUPER,btn_right,moveresize,curresize

  # Rules
  windowrule=isfloating:1,width:875,height:600,appid:^(xdg-desktop-portal-gtk|xdg-desktop-portal-kde|sublime_text|DesktopEditors|org.gnome.Nautilus|org.kde.dolphin)$,title:^(Open.*Files?|Open [F|f]older.*|Save.*Files?|Save.*As|Save|All Files|.*wants to [open|save].*|[C|c]hoose.*)
  windowrule=isfloating:1,width:875,height:600,appid:^(org.fuzi.terminal|org.fuzi.bash|org.gnome.NautilusPreviewer|org.gnome.Evince|com.gabm.satty|About|TUI.float|imv|mpv|feh|org.kde.gwenview)$
  windowrule=isfloating:1,appid:^org.gnome.Calculator$
  windowrule=isfloating:1,isnoborder:1,isoverlay:1,width:600,height:338,offsetx:75,offsety:-75,title:(Picture.?in.?[Pp]icture)
  windowrule=isterm:1,appid:^(Alacritty|kitty|com.mitchellh.ghostty)$
'';
}
