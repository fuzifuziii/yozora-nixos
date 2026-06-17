{
  programs.nixcord = {
    enable = true;
    user = "fuzifuziii";
    discord = {
      vencord.enable = true;
      krisp.enable = true;
      openASAR.enable = true;
      settings = {
        SKIP_HOST_UPDATE = true;
      };
    };
    config = {
      autoUpdate = true;
      autoUpdateNotification = true;
      frameless = true;
      enabledThemes = [ "midnight.css" ];

      plugins = {
        clearUrls.enable = true;
        fakeNitro.enable = true;
        fixImagesQuality.enable = true;
        gameActivityToggle.enable = true;
        crashHandler.enable = true;
        messageLatency.enable = true;
        gifPaste.enable = true;
      };
    };
  };
}
