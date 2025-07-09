{ pkgs, ... }:
{
  fonts = {
    packages = with pkgs; [
      font-awesome
      wqy_zenhei
    ];
  };
}
