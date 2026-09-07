{
  xdg.configFile."hyprland-preview-share-picker/config.yaml".text = ''
  stylesheets: ["../hyprland-preview-share-picker/style.css"]
  default_page: outputs
  window:
    height: 500
    width: 1000
  image:
    resize_size: 500
    widget_size: 150
  classes:
    window: window
    image_card: card
    image_card_loading: card-loading
    image: image
    image_label: image-label
    notebook: notebook
    tab_label: tab-label
    notebook_page: page
    region_button: region-button
    restore_button: restore-button
  windows:
    min_per_row: 3
    max_per_row: 999
    clicks: 1
    spacing: 12
  outputs:
    clicks: 1
    spacing: 6
    show_label: false
    respect_output_scaling: true
  region:
    command: slurp -f '%o@%x,%y,%w,%h'
  hide_token_restore: true
  debug: false
'';

xdg.configFile."hyprland-preview-share-picker/style.css".text = ''
  @define-color foreground #c0caf5;
  @define-color background #1a1b26;
  @define-color accent #7aa2f7;
  @define-color muted #565f89;
  @define-color card_bg #24283b;
  @define-color text_dark #15161e;
  @define-color accent_hover #9ec1ff;
  @define-color selected_tab #7dcfff;
  @define-color text #c0caf5;
  * {
    all: unset;
    font-family: JetBrains Mono NF;
    color: @foreground;
    font-weight: bold;
    font-size: 16px;
  }
  window {
    background: @background;
  }
  window > box {
    border: 2px solid #33CCFF;
    background-color: @background;
  }
  tabs {
    padding: 0.5rem 1rem;
    border: 2px solid #33CCFF;
  }
  tabs > tab {
      margin-right: 1rem;
  }
  .tab-label {
      color: @text;
      transition: all 0.2s ease;
  }
  tabs > tab:checked > .tab-label, tabs > tab:active > .tab-label {
      text-decoration: underline currentColor;
      color: @selected_tab;
  }
  tabs > tab:focus > .tab-label {
      color: @foreground;
  }
  .page {
      padding: 1rem;
  }
  .image-label {
      font-size: 12px;
      padding: 0.25rem;
  }
  flowboxchild > .card, button > .card {
      transition: all 0.2s ease;
      border: solid 2px transparent;
      border-color: @background;
      border-radius: 5px;
      background-color: @card_bg;
      padding: 5px;
  }
  flowboxchild:hover > .card, button:hover > .card, flowboxchild:active > .card, flowboxchild:selected > .card, button:active > .card, button:selected > .card, button:focus > .card {
      border: solid 2px @accent;
  }
  .image {
      border-radius: 5px;
  }
  .region-button {
      padding: 0.5rem 1rem;
      border-radius: 5px;
      background-color: @accent;
      color: @text_dark;
      transition: all 0.2s ease;
  }
  .region-button > label {
      color: @text_dark;
  }
  .region-button:not(:disabled):hover, .region-button:not(:disabled):focus {
      background-color: @accent_hover;
      color: @text_dark;
  }
  .region-button:disabled {
      background-color: @muted;
      color: @background;
  }
'';
}
