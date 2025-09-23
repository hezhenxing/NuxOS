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
        pkgs=`command-not-found "$1" |& sed -n 's/^  nix-shell -p \(.*\)/\1/p'`
        if [ -n "$pkgs" ]; then
          echo "The program '$1' is not in your PATH. You can make it available by temporarily install one of the following packages:" 1>&2
          PS3="Choose a package or press Ctrl-C to cancel: "
          setopt shwordsplit
          select pkg in $pkgs; do
            case $pkg in
              "")
                echo "Invalid option, please try again!" 1>&2
                ;;
              *)
                break
                ;;
            esac
          done
          unsetopt shwordsplit
          echo "You chose package '$pkg'" 1>&2
          nix shell nixpkgs#$pkg --command "''${@}"
        else
          echo "command not found: $1" 1>&2
          return 127
        fi
      }
    '';
  };
}
