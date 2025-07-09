{
  pkgs,
  nuxos,
  ...
}: {
  imports = with nuxos.homeModules; [
    betterlockscreen
    picom
    polybar
  ];
  home.packages = with pkgs; [
    brave
    brightnessctl
    google-chrome
    kitty
    rofi
  ];
  services.dunst.enable = true;
  xsession = {
    enable = true;
    windowManager.xmonad = {
      enable = true;
      enableContribAndExtras = true;
      config = ./xmonad.hs;
    };
  };
}
