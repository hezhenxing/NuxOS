{ pkgs, ... }:
{
  fonts = {
    packages = with pkgs; [
      font-awesome
      material-icons
      symbola
      wqy_zenhei
    ];
  };
}
