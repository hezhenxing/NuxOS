{ nuxos, ... }:
{
  imports = with nuxos.nixosModules; [
    polkit
    sddm
    xserver
  ];
  services.desktopManager.plasma6.enable = true;
}
