{ inputs, ... }:
{
  imports = [ inputs.nvf.homeManagerModules.default ];

  programs.nvf = {
    enable = true;

    settings.vim = {
      vimAlias = true;
      viAlias = true;

      options = {
        tabstop = 2;
        shiftwidth = 2;
      };

      lsp = {
        enable = true;
        formatOnSave = true;
      };

      languages = {
        enableFormat = true;
        nix.enable = true;
        clang.enable = true;
        python.enable = true;
        markdown.enable = true;
      };

      git.enable = true;
    };
  };
}
