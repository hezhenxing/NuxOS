{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flakelight = {
      url = "github:nix-community/flakelight";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    stylix = {
      url = "github:nix-community/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nux = {
      url = "github:hezhenxing/nux";
    };
  };
  outputs =
    inputs@{
      nixpkgs,
      flakelight,
      home-manager,
      stylix,
      nux,
      ...
    }:
    flakelight ./. {
      inherit inputs;
      imports = [
        flakelight.flakelightModules.extendFlakelight
        ./nuxos.nix
      ];
      flakelightModule =
        { lib, ... }:
        {
          imports = [ ./nuxos.nix ];
          inputs.home-manager = lib.mkDefault home-manager;
          inputs.stylix = lib.mkDefault stylix;
          inputs.nux = lib.mkDefault nux;
          nixpkgs.config = {
            allowUnfree = true;
          };
        };
      nixpkgs.config = {
        allowUnfree = true;
      };
    };
}
