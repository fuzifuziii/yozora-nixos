{
programs.fish = {
  enable = true;

  shellInit = ''
    function fish_prompt -d "Write out the prompt"
        printf '%s@%s %s%s%s > ' $USER $hostname \
            (set_color $fish_color_cwd) (prompt_pwd) (set_color normal)
    end

    if status is-interactive
        set fish_greeting

        fastfetch

        alias ff "fastfetch"
        alias zap "sudo bash /home/fuzifuziii/.local/share/zapret-discord-youtube-linux/main_script.sh -nointeractive"
        alias zapt "sudo nvim ~/.local/share/zapret-discord-youtube-linux/conf.env"

        function sudo
            if test "$argv[1]" = nvim
                command sudo -E $argv
            else
                command sudo $argv
            end
        end
    end
  '';
};
}

