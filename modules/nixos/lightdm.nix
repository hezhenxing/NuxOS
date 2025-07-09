{ config, ... }:
let
  inherit (builtins) elemAt;
  inherit (config.services.displayManager.sessionData)
    sessionNames
    ;
in
{
  services.xserver.displayManager.lightdm = {
    enable = true;
    greeters.slick = {
      enable = true;
    };
  };
  services.displayManager.defaultSession = elemAt sessionNames 0;
}
