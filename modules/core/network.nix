{
  pkgs,
  hostname,
  ...
}: {
  networking = {
    hostName = "${hostname}";
    networkmanager.enable = true;
    firewall = {
      enable = true;
      allowedTCPPorts = [
        22
      ];
    };
  };
  environment.systemPackages = [pkgs.networkmanagerapplet];
}
