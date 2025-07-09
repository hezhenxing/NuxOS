{
  hardware = {
    graphics.enable = true;
    bluetooth = {
      enable = true;
      powerOnBoot = true;
    };
    keyboard.qmk.enable = true;
    enableRedistributableFirmware = true;
  };

  services = {
    blueman.enable = true;
    fstrim.enable = true; # SSD optimizer
    gvfs.enable = true;

    pipewire = {
      enable = true;
      alsa = {
        enable = true;
        support32Bit = true;
      };
      pulse.enable = true;
    };
  };

  home-manager.sharedModules = [
    {
      services.udiskie.enable = true;
    }
  ];
}
