{ inputs, pkgs, ... }: 
{
  home.packages = [
    inputs.sidra.packages.${pkgs.system}.default
  ];

  programs.home-manager.enable = true;
  programs.lazyvim.enable = true;
  programs.nixcord = {
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
}
