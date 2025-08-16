{
  lib,
  inputs,
  nuxos,
  pkgs,
  options,
  hostname,
  host,
  users,
  ...
}:
let
  inherit (builtins)
    hasAttr
    mapAttrs
    ;
  inherit (lib)
    attrByPath
    importJSON
    setAttrByPath
    splitString
    ;
  opts = importJSON nuxos.homeOptionsJson;
  packages = importJSON nuxos.packagesJson;
  isMod = name: hasAttr name nuxos.homeModules;
  isOpt = name: hasAttr name opts;
  isPkg = name: hasAttr name packages;
  mkMod = name: nuxos.homeModules.${name};
  mkOpt =
    name:
    let
      optname = opts.${name};
      parts = splitString "." optname;
    in
    setAttrByPath parts { enable = true; };
  mkPkg =
    name:
    let
      pkgname = packages.${name};
      parts = splitString "." pkgname;
    in
    {
      home.packages = [
        (attrByPath parts null pkgs)
      ];
    };
  mkAuto =
    name:
    if isMod name then
      mkMod name
    else if isOpt name then
      mkOpt name
    else if isPkg name then
      mkPkg name
    else
      throw "invalid home auto name: ${name}";
  hmUser =
    username: usercfg:
    let
      autos = map mkAuto usercfg.autos;
    in
    {
      home = {
        inherit username;
        homeDirectory = "/home/${username}";
      };
      imports = autos;
    };
  hmUsers = mapAttrs hmUser users;
in
{
  imports = [
    inputs.home-manager.nixosModules.home-manager
  ];

  home-manager = {
    useUserPackages = true;
    useGlobalPkgs = true;
    extraSpecialArgs = {
      inherit
        inputs
        nuxos
        hostname
        host
        users
        ;
    };
    sharedModules = [
      {
        imports = with nuxos.homeModules; [
          gtk
          xdg
          zsh
        ];
        home.stateVersion = "25.11";
      }
    ];
    users = hmUsers;
  };
}
