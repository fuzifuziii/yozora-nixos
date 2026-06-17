{
  wayland.windowManager.hyprland.settings.exec-once = [
  "uwsm-app -- mako"
  "uwsm-app -- waybar --config ~/.config/waybar/config --style ~/.config/waybar/theme/waybar.css"
  #"uwsm-app -- waybar"
  "uwsm-app -- swaybg -i Pictures/bg.jpg -m fill"
  "uwsm-app -- swayosd-server"
  "uwsm-app -- bitwarden"

  "systemctl --user import-environment $(env | cut -d'=' -f 1)"
  "dbus-update-activation-environment --systemd --all"
  "uwsm-app -- /run/current-system/sw/libexec/polkit-kde-authentication-agent-1"

  "gsettings set org.gnome.desktop.interface gtk-theme 'Tokyonight-Dark'"
  "otd-daemon"
  ];
}
