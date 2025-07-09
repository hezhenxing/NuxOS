{ nuxos, ... }:
{
  imports = with nuxos.nixosModules; [
    lightdm
    xserver
  ];
  programs.i3lock.enable = true;
  services.xserver.windowManager.xmonad.enable = true;
  home-manager.sharedModules = with nuxos.homeModules; [
    xmonad
  ];
}
