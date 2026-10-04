{ inputs, pkgs, ... }: 
{
  programs = {
    home-manager.enable = true;
    cargo.enable = true;

    # Apps
    lazyvim.enable = true;
    nixcord = {
      enable = true;
      discord = {
        vencord.enable = true;
        krisp.enable = true;
      };
      config = {
        useQuickCss = true;
        enabledThemes = [ "tokyo.css" ];
        plugins = {
          fakeNitro.enable = true;
          gameActivityToggle.enable = true;
          noTypingAnimation.enable = true;
        };
      };
    };
  };
}
