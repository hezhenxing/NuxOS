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
    nvf = {
      url = "github:notashelf/nvf";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs =
    inputs@{
      nixpkgs,
      flakelight,
      home-manager,
      stylix,
      nux,
      nvf,
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
          inputs.nvf = lib.mkDefault nvf;
          nixpkgs.config = {
            allowUnfree = true;
          };
        };
      nixpkgs.config = {
        allowUnfree = true;
      };
      devShell.packages =
        pkgs:
        let
          rev = nixpkgs.rev;
          homeOptions = "${home-manager.packages.x86_64-linux.docs-json.outPath}/share/doc/home-manager/options.json";
          update = pkgs.writeShellScriptBin "update" ''
            find_flake_root() {
              while true; do
                if [[ -f flake.nix ]]; then
                  echo "$PWD"
                  return
                elif [[ "$PWD" = "/" ]]; then
                  echo "ERROR: Not in a flake directory"
                else
                  cd ..
                fi
              done
            }
            find_flake_root
            rm -f data/{options.json,home-options.json,packages.json}
            echo "Fetching sources.json"
            dir=$(curl -sL https://github.com/wamserma/flake-programs-sqlite/raw/refs/heads/main/sources.json | jq -r '."${rev}".url | rtrimstr("/nixexprs.tar.xz")')
            url=https://releases.nixos.org$dir
            options_url=$url/options.json.br
            packages_url=$url/packages.json.br
            echo "Fetching and generating options.json"
            curl -sL $options_url | brotli -dc | jq -f scripts/options.jq > data/options.json
            echo "Reading and generating home-options.json"
            jq -f scripts/options.jq ${homeOptions}  > data/home-options.json
            echo "Fetching and generating packages.json"
            curl -sL $packages_url | brotli -dc | jq -f scripts/packages.jq > data/packages.json
          '';
        in
        with pkgs;
        [
          curl
          jq
          update
        ];
    };
}
