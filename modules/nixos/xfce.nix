{ nuxos, pkgs, ... }:
{
  imports = with nuxos.nixosModules; [
    lightdm
    xserver
  ];
  services.xserver.desktopManager.xfce.enable = true;
}
