{ nuxos, ... }:
{
  imports = with nuxos.nixosModules; [
    sddm
    xserver
  ];
  services.desktopManager.plasma6.enable = true;
}
