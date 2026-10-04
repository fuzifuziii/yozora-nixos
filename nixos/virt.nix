{ pkgs, ... }:
{
  users.users.fuzifuziii.extraGroups = [ "libvirtd" ];

  environment.systemPackages = with pkgs; [
    gnome-boxes
  ];

  virtualisation.libvirtd.enable = true;
  virtualisation.spiceUSBRedirection.enable = true;
}
