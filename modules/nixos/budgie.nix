{ nuxos, ... }:
{
  imports = with nuxos.nixosModules; [
    lightdm
    polkit
    xserver
  ];
  services.xserver.desktopManager.budgie.enable = true;
}
