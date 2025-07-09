{
  services.xserver = {
    enable = true;
    dpi = 120;
    displayManager.startx.enable = true;
  };
  services.libinput = {
    enable = true;
    touchpad.naturalScrolling = true;
  };
}
