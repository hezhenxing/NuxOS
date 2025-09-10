{ pkgs, ... }:
{
  xdg = {
    enable = true;
    mime.enable = true;
    mimeApps.enable = true;
    configFile."mimeapps.list".force = true;
  };
}
