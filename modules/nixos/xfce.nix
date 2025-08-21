{ nuxos, pkgs, ... }:
{
  imports = with nuxos.nixosModules; [
    lightdm
    polkit
    xserver
  ];
  services.xserver.desktopManager.xfce.enable = true;
}
