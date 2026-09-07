{ pkgs, ... }:
{
  programs.fish = {
    enable = true;

    interactiveShellInit = ''
      set fish_greeting
      fastfetch
    '';

    functions = {
      fish_prompt = {
        description = "Write out the prompt";
        body = ''
          printf '%s@%s %s%s%s > ' $USER $hostname \
              (set_color $fish_color_cwd) (prompt_pwd) (set_color normal)
        '';
      };

      # Lazyvim with sudo
      sudo = {
        body = ''
          if test "$argv[1]" = nvim
              command sudo -E $argv
          else
              command sudo $argv
          end
        '';
      };
    };
  };

  home.packages = [ pkgs.fastfetch ];
}
