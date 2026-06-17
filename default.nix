{
  imports = [
      ./hardware-configuration.nix
      #./nvidia.nix

      ./system.nix
      ./power.nix
      ./input.nix

      ./desktop.nix
      ./shell.nix
      ./programs.nix
      ./services.nix
      ./libs.nix
      ./fonts.nix

      ./hyprland.nix
      ./discord.nix

      #./java.nix
      #./davinci.nix

      #./home.nix
    ];
}
