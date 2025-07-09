{pkgs, ...}: {
  programs.waybar = {
    enable = true;
    package = pkgs.waybar;
  };

  home.file.".config/waybar/power_menu.xml" = {
    enable = true;
    source = ./power_menu.xml;
  };

  systemd.user.targets.graphical-session.Unit.Wants = [
    "waybar.service"
  ];
}
