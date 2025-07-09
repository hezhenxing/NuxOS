{ pkgs, ... }:
{
  services.displayManager.sddm = {
    enable = true;
    enableHidpi = true;
  };
}
