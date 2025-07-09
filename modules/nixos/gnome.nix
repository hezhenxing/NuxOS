{ nuxos, ... }:
{
  imports = with nuxos.nixosModules; [
    gdm
    xserver
  ];
  services.desktopManager.gnome.enable = true;
}
