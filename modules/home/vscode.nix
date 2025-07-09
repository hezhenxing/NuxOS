{ pkgs, ... }:
{
  programs.vscode = {
    enable = true;
    mutableExtensionsDir = true;

    profiles.default = {
      enableUpdateCheck = false;
      enableExtensionUpdateCheck = false;
      extensions = with pkgs.vscode-extensions; [
        bbenoist.nix
        jnoortheen.nix-ide
        arrterian.nix-env-selector
        haskell.haskell
        justusadam.language-haskell
        eamodio.gitlens
        ms-python.python
        golang.go
      ];

      userSettings = {
        "editor.tabSize" = 2;
        "editor.formatOnSave" = true;
        "files.insertFinalNewline" = true;
        "files.trimTrailingWhitespace" = true;
        "haskell.formattingProvider" = "stylish-haskell";
        "nixEnvSelector.useFlakes" = true;
      };
    };
  };
}
