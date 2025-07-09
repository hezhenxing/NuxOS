{ nuxos, ... }:
{
  imports = with nuxos.nixosModules; [
    greetd
  ];
  programs.hyprland.enable = true;
  services.power-profiles-daemon.enable = true;
  home-manager.sharedModules = [
    nuxos.homeModules.hyprland
  ];
}
