{pkgs, ...}: {
  home.packages = with pkgs; [
    brave
    kitty
    rofi
  ];

  wayland.windowManager.hyprland = {
    enable = true;
    package = pkgs.hyprland;
    systemd = {
      enable = true;
    };
    settings = {
      general = {
        "$modifier" = "SUPER";
      };
      bind = [
        "$modifier,Return,exec,kitty"
        "$modifier SHIFT,Return,exec,rofi -show drun"
        "$modifier,K,exec,list-keybinds"
        "$modifier,W,exec,brave"
        "$modifier,P,pseudo,"
        "$modifier,F,fullscreen,"
        "$modifier SHIFT,F,togglefloating,"
        "$modifier,C,killactive"
        "$modifier SHIFT,C,exit"
        "$modifier,h,movefocus,l"
        "$modifier,l,movefocus,r"
        "$modifier,k,movefocus,u"
        "$modifier,j,movefocus,d"
        "$modifier,1,workspace,1"
        "$modifier,2,workspace,2"
        "$modifier,3,workspace,3"
        "$modifier,4,workspace,4"
        "$modifier,5,workspace,5"
        "$modifier,6,workspace,6"
        "$modifier,7,workspace,7"
        "$modifier,8,workspace,8"
        "$modifier,9,workspace,9"
        "ALT,TAB,cyclenext"
        "ALT,TAB,bringactivetotop"
      ];
    };
  };
}
