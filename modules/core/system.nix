{
  inputs,
  pkgs,
  host,
  ...
}:
{
  system = {
    stateVersion = "25.11";
    nixos.label = "NuxOS";
  };
  fileSystems = host.fileSystems;
  environment = {
    variables = {
      NUXOS = "true";
      NUXOS_VERSION = "0.1";
    };
    shells = with pkgs; [
      bash
      zsh
    ];
    systemPackages = with pkgs; [
      nh
      inputs.nux.packages.x86_64-linux.default
    ];
  };
  virtualisation.vmVariant.virtualisation = {
    memorySize = 2048;
    cores = 2;
  };
  nix.settings = {
    download-buffer-size = 250000000;
    auto-optimise-store = true;
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    substituters = [
      "https://hyprland.cachix.org"
      "https://nix-community.cachix.org"
    ];
    trusted-public-keys = [
      "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };
}
