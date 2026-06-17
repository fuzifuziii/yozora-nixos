{ config, pkgs, lib, fonts, ... }:
{
    fonts.packages = with pkgs; [
  noto-fonts
  noto-fonts-cjk-sans
  noto-fonts-cjk-serif
  noto-fonts-cjk-sans-static
  noto-fonts-cjk-serif-static
  noto-fonts-lgc-plus
  noto-fonts-color-emoji
  liberation_ttf
  jetbrains-mono
  nerd-fonts.jetbrains-mono
  corefonts
  vista-fonts
];
    fonts.fontconfig.useEmbeddedBitmaps = true;
  }
