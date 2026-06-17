{ config, pkgs, lib, fonts, lazyvim, ... }:
{
  imports = [ lazyvim.homeManagerModules.default ];
  programs.lazyvim.enable = true;

  programs.neovim = {
    enable = true;
    defaultEditor = true;
  };
  xdg.configFile."nvim/lua/plugins/neovim.lua".text = ''
return {
	{
		"folke/tokyonight.nvim",
		priority = 1000,
	},
	{
		"LazyVim/LazyVim",
		opts = {
			colorscheme = "tokyonight-night",
		},
	},
}
  '';
}

