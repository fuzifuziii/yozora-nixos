{
  xdg.configFile."walker/config.toml".text = ''
force_keyboard_focus = true                                                 # forces keyboard forcus to stay in Walker
selection_wrap = true                                                       # wrap list if at bottom or top
theme = "fuzi-default"                                                   # theme to use
additional_theme_location = "~/.local/share/fuzi/default/walker/themes/"
hide_action_hints = true                                                    # globally hide the action hints

[placeholders]
"default" = { input = "Search...", list = "No Results" } # placeholders for input and empty list, key is the providers name, so f.e. "desktopapplications" or "menus:other"

[keybinds]
quick_activate = []

[columns]
symbols = 1 # providers to be queried by default

[providers]
max_results = 256 # 256 should be enough for everyone
default = [
  "desktopapplications",
]

[[providers.prefixes]]
prefix = "/"
provider = "providerlist"

[[providers.prefixes]]
prefix = "."
provider = "files"

[[providers.prefixes]]
prefix = ":"
provider = "symbols"

[[providers.prefixes]]
prefix = "="
provider = "calc"

[[providers.prefixes]]
prefix = "@"
provider = "websearch"

[[providers.prefixes]]
prefix = "$"
provider = "clipboard"

[[emergencies]]
text = "Restart Walker"
command = "fuzi-restart-walker"
  '';
  xdg.configFile."walker/themes/fuzi-default/layout.xml".text = ''
<?xml version="1.0" encoding="UTF-8"?>
<interface>
  <requires lib="gtk" version="4.0"></requires>
  <object class="GtkWindow" id="Window">
    <style>
      <class name="window"></class>
    </style>
    <property name="resizable">true</property>
    <property name="title">Walker</property>
    <child>
      <object class="GtkBox" id="BoxWrapper">
        <style>
          <class name="box-wrapper"></class>
        </style>
        <property name="width-request">644</property>
        <property name="overflow">hidden</property>
        <property name="orientation">horizontal</property>
        <property name="valign">center</property>
        <property name="halign">center</property>
        <child>
          <object class="GtkBox" id="Box">
            <style>
              <class name="box"></class>
            </style>
            <property name="orientation">vertical</property>
            <property name="hexpand-set">true</property>
            <property name="hexpand">true</property>
            <property name="spacing">10</property>
            <child>
              <object class="GtkBox" id="SearchContainer">
                <style>
                  <class name="search-container"></class>
                </style>
                <property name="overflow">hidden</property>
                <property name="orientation">horizontal</property>
                <property name="halign">fill</property>
                <property name="hexpand-set">true</property>
                <property name="hexpand">true</property>
                <child>
                  <object class="GtkEntry" id="Input">
                    <style>
                      <class name="input"></class>
                    </style>
                    <property name="halign">fill</property>
                    <property name="hexpand-set">true</property>
                    <property name="hexpand">true</property>
                  </object>
                </child>
              </object>
            </child>
            <child>
              <object class="GtkBox" id="ContentContainer">
                <style>
                  <class name="content-container"></class>
                </style>
                <property name="orientation">horizontal</property>
                <property name="spacing">10</property>
                <property name="vexpand">true</property>
                <property name="vexpand-set">true</property>
                <child>
                  <object class="GtkLabel" id="ElephantHint">
                    <style>
                      <class name="elephant-hint"></class>
                    </style>
                    <property name="hexpand">true</property>
                    <property name="height-request">100</property>
                    <property name="label">Waiting for elephant...</property>
                  </object>
                </child>
                <child>
                  <object class="GtkLabel" id="Placeholder">
                    <style>
                      <class name="placeholder"></class>
                    </style>
                    <property name="label">No Results</property>
                    <property name="yalign">0.0</property>
                    <property name="hexpand">true</property>
                  </object>
                </child>
                <child>
                  <object class="GtkScrolledWindow" id="Scroll">
                    <style>
                      <class name="scroll"></class>
                    </style>
                    <property name="hexpand">true</property>
                    <property name="can_focus">false</property>
                    <property name="overlay-scrolling">true</property>
                    <property name="max-content-width">600</property>
                    <property name="max-content-height">300</property>
                    <property name="min-content-height">0</property>
                    <property name="propagate-natural-height">true</property>
                    <property name="propagate-natural-width">true</property>
                    <property name="hscrollbar-policy">automatic</property>
                    <property name="vscrollbar-policy">automatic</property>
                    <child>
                      <object class="GtkGridView" id="List">
                        <style>
                          <class name="list"></class>
                        </style>
                        <property name="max_columns">1</property>
                        <property name="can_focus">false</property>
                      </object>
                    </child>
                  </object>
                </child>
                <child>
                  <object class="GtkBox" id="Preview">
                    <style>
                      <class name="preview"></class>
                    </style>
                  </object>
                </child>
              </object>
            </child>
            <child>
              <object class="GtkBox" id="Keybinds">
                <property name="hexpand">true</property>
                <property name="margin-top">10</property>
                <style>
                  <class name="keybinds"></class>
                </style>
                <child>
                  <object class="GtkBox" id="GlobalKeybinds">
                    <property name="spacing">10</property>
                    <style>
                      <class name="global-keybinds"></class>
                    </style>
                  </object>
                </child>
                <child>
                  <object class="GtkBox" id="ItemKeybinds">
                    <property name="hexpand">true</property>
                    <property name="halign">end</property>
                    <property name="spacing">10</property>
                    <style>
                      <class name="item-keybinds"></class>
                    </style>
                  </object>
                </child>
              </object>
            </child>
            <child>
              <object class="GtkLabel" id="Error">
                <style>
                  <class name="error"></class>
                </style>
                <property name="xalign">0</property>
                <property name="visible">false</property>
              </object>
            </child>
          </object>
        </child>
      </object>
    </child>
  </object>
</interface>
  '';
  xdg.configFile."walker/themes/fuzi-default/style.css".text = ''
@import "../../../../.config/walker/walker.css";

* {
  all: unset;
}

* {
  font-family: monospace;
  font-size: 18px;
  color: @text;
}

scrollbar {
  opacity: 0;
}

.normal-icons {
  -gtk-icon-size: 16px;
}

.large-icons {
  -gtk-icon-size: 32px;
}

.box-wrapper {
  background: alpha(@base, 0.95);
  padding: 20px;
  border: 2px solid @border;
}

.preview-box {
}

.box {
}

.search-container {
  background: @base;
  padding: 10px;
}

.input placeholder {
  opacity: 0.5;
}

.input {
}

.input:focus,
.input:active {
  box-shadow: none;
  outline: none;
}

.content-container {
}

.placeholder {
}

.scroll {
}

.list {
}

child,
child > * {
}

child:hover .item-box {
}

child:selected .item-box {
}

child:selected .item-box * {
  color: @selected-text;
}

.item-box {
  padding-left: 14px;
}

.item-text-box {
  all: unset;
  padding: 14px 0;
}

.item-text {
}

.item-subtext {
  font-size: 0px;
  min-height: 0px;
  margin: 0px;
  padding: 0px;
}

.item-image {
  margin-right: 14px;
  -gtk-icon-transform: scale(0.9);
}

.current {
  font-style: italic;
}

.keybind-hints {
  background: @background;
  padding: 10px;
  margin-top: 10px;
}

.preview {
}
  '';
  xdg.configFile."walker/walker.css".text = ''
@define-color selected-text #7dcfff;
@define-color text #cfc9c2;
@define-color base #1a1b26;
@define-color border #33ccff;
@define-color foreground #cfc9c2;
@define-color background #1a1b26;
  '';
}
