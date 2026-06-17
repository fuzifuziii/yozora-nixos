{
  programs.kitty = {
    enable = true;
    settings = {
      include = "~/.config/kitty/theme/kitty.conf";
      window_padding_width = 14;
      hide_window_decorations = true;
      confirm_os_window_close = 0;
      enable_audio_bell = false;
      allow_remote_control = true;
      cursor_shape = "block";
      tab_bar_edge = "bottom";
      tab_bar_style = "powerline";
      tab_powerline_style = "slanted";
      tab_title_template =
        "{title}{' :{}:'.format(num_windows) if num_windows > 1 else ''}";
    };
  };
  xdg.configFile."kitty/theme/kitty.conf".text = ''
background #1a1b26
foreground #c0caf5
selection_background #283457
selection_foreground #c0caf5
url_color #73daca
cursor #c0caf5
cursor_text_color #1a1b26
active_tab_background #7aa2f7
active_tab_foreground #16161e
inactive_tab_background #292e42
inactive_tab_foreground #545c7e
#tab_bar_background #15161e
active_border_color #7aa2f7
inactive_border_color #292e42
color0 #15161e
color1 #f7768e
color2 #9ece6a
color3 #e0af68
color4 #7aa2f7
color5 #bb9af7
color6 #7dcfff
color7 #a9b1d6
color8 #414868
color9 #f7768e
color10 #9ece6a
color11 #e0af68
color12 #7aa2f7
color13 #bb9af7
color14 #7dcfff
color15 #c0caf5
color16 #ff9e64
color17 #db4b4b
  '';
}

