{ nuxos, ... }:
{
  imports = with nuxos.nixosModules; [
    gdm
    polkit
    xserver
  ];
  services.desktopManager.gnome.enable = true;
}
