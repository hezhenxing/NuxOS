{
  pkgs,
  config,
  ...
}:
let
  audioctl = pkgs.writeShellScriptBin "audioctl" ''
    case $1 in
      "up")
        ${pkgs.wireplumber}/bin/wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%+
        ;;
      "down")
        ${pkgs.wireplumber}/bin/wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-
        ;;
      "mute")
        ${pkgs.wireplumber}/bin/wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
        ;;
    esac
    ${pkgs.wireplumber}/bin/wpctl get-volume @DEFAULT_AUDIO_SINK@ | ${pkgs.gnused}/bin/sed -e 's/Volume: //;s/0\.00/0/;s/0\.0/0/;s/0\.//;s/\.//;s/\([0-9]*\) *\(.*\)/VOL\2\1%/;s/VOL\[MUTED\]/ /;s/VOL/%{F#F0C674} %{F-}/'
  '';
in
{
  home.packages = [
    audioctl
  ];
  programs.wlogout.enable = true;
  services.polybar = {
    enable = true;
    script = ''
      export PATH=$PATH:${config.home.path}/bin:/run/current-system/sw/bin
      polybar &
    '';
    config = ./config.ini;
  };
}
