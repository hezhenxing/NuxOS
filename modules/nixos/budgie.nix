{ nuxos, ... }:
{
  imports = with nuxos.nixosModules; [
    lightdm
    xserver
  ];
  services.xserver.desktopManager.budgie.enable = true;
}
