{ pkgs, nuxos, ... }:
{
  imports = with nuxos.homeModules; [
    git
    nixfmt
    nvf
    vscode
  ];

  home.packages = with pkgs; [
    cloc
  ];

  programs = {
    direnv.enable = true;
    helix.enable = true;
    jq.enable = true;
    ripgrep.enable = true;
  };
}
