{
  pkgs,
  lib,
  ...
}:
{
  programs.zsh = {
    enable = true;
    # autosuggestion.enable = true;
    # syntaxHighlighting.enable = true;
    oh-my-zsh.enable = true;
    plugins = [
      {
        name = "powerlevel10k";
        src = pkgs.zsh-powerlevel10k;
        file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
      }
      {
        name = "powerlevel10k-config";
        src = lib.cleanSource ./p10k-config;
        file = "p10k.zsh";
      }
    ];
    initContent = ''
      function command_not_found_handler() {
        cmd=`command-not-found "$1" |& sed -n '3p'`
        if [ -n "$cmd" ]; then
          eval "$cmd --command \"$@:q\""
        else
          echo "command not found: $1" 1>&2
          return 127
        fi
      }
    '';
  };
}
