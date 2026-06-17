{ ... }:
{
  wayland.windowManager.hyprland.settings = {
    windowrule = [
      "suppress_event maximize, match:class .*"
      "no_focus on, match:class ^$, match:title ^$, match:xwayland 1, match:float 1, match:fullscreen 0, match:pin 0"
      "no_screen_share on, match:class com.ayugram.desktop"
      "float on, match:title playit"

      "no_screen_share on, match:class ^(1[p|P]assword)$"
      "tag +floating-window, match:class ^(1[p|P]assword)$"

      "tag +chromium-based-browser, match:class ((google-)?[cC]hrom(e|ium)|[bB]rave-browser|[mM]icrosoft-edge|Vivaldi-stable|helium)"
      "tag +firefox-based-browser, match:class ([fF]irefox|zen|librewolf)"
      "tile on, match:tag chromium-based-browser"
      "opacity 1 0.97, match:tag chromium-based-browser"
      "opacity 1 0.97, match:tag firefox-based-browser"
      "opacity 1.0 1.0, match:initial_title ((?i)(?:[a-z0-9-]+\.)*youtube\.com_/|app\.zoom\.us_/wc/home)"

      "tag +jetbrains-splash, match:class ^(jetbrains-.*)$, match:title ^(splash)$, match:float 1"
      "center on, match:tag jetbrains-splash"
      "no_focus on, match:tag jetbrains-splash"
      "border_size 0, match:tag jetbrains-splash"
      "tag +jetbrains, match:class ^(jetbrains-.*), match:title ^()$, match:float 1"
      "center on, match:tag jetbrains"
      "stay_focused on, match:tag jetbrains"
      "border_size 0, match:tag jetbrains"
      "min_size (monitor_w*0.5) (monitor_h*0.5), match:class ^(jetbrains-.*), match:title ^()$, match:float 1"
      "no_initial_focus on, match:class ^(jetbrains-.*)$, match:title ^(win.*)$, match:float 1"
      "no_follow_mouse on, match:class ^(jetbrains-.*)$"

      "tag +pip, match:title (Picture.?in.?[Pp]icture)"
      "float on, match:tag pip"
      "pin on, match:tag pip"
      "size 600 338, match:tag pip"
      "keep_aspect_ratio on, match:tag pip"
      "border_size 0, match:tag pip"
      "opacity 1 1, match:tag pip"
      "move (monitor_w-window_w-40) (monitor_h*0.04), match:tag pip"

      "opacity 1 1, match:class qemu"

      "float on, match:tag floating-window"
      "center on, match:tag floating-window"
      "size 875 600, match:tag floating-window"
      "tag +floating-window, match:class (org.omarchy.bluetui|org.omarchy.impala|org.omarchy.wiremix|org.omarchy.btop|org.omarchy.terminal|org.omarchy.bash|org.gnome.NautilusPreviewer|org.gnome.Evince|com.gabm.satty|Omarchy|About|TUI.float|imv|mpv|org.kde.gwenview|org.omarchy.playit)"
      "tag +floating-window, match:class (xdg-desktop-portal-gtk|sublime_text|DesktopEditors|org.gnome.Nautilus), match:title ^(Open.*Files?|Open [F|f]older.*|Save.*Files?|Save.*As|Save|All Files|.*wants to [open|save].*|[C|c]hoose.*)"
      "float on, match:class org.gnome.Calculator"
      "fullscreen on, match:class org.omarchy.screensaver"
      "float on, match:class org.omarchy.screensaver"
      "opacity 1 1, match:class ^(zoom|vlc|mpv|org.kde.kdenlive|com.obsproject.Studio|com.github.PintaProject.Pinta|imv|org.gnome.NautilusPreviewer)$"
      "rounding 8, match:tag pop"
      "idle_inhibit always, match:tag noidle"

      "tag +terminal, match:class (Alacritty|kitty|com.mitchellh.ghostty)"

      "match:class (Alactritty|kitty), scroll_touchpad 1.5"
      "match:class com.mitchellh.ghostty, scroll_touchpad 0.2"
    ];

    layerrule = [
      "no_screen_share on, match:namespace notifications"
      "no_anim on, match:namespace selection"
      "no_anim on, match:namespace walker"
    ];
  };
}
