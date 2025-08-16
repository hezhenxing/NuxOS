{
  lib,
  pkgs,
  nuxos,
  host,
  ...
}:
let
  inherit (builtins)
    groupBy
    hasAttr
    ;
  inherit (lib)
    attrByPath
    importJSON
    setAttrByPath
    splitString
    ;
  opts = importJSON nuxos.optionsJson;
  packages = importJSON nuxos.packagesJson;
  isMod = name: hasAttr name nuxos.nixosModules;
  isOpt = name: hasAttr name opts;
  isPkg = name: hasAttr name packages;
  mkMod = name: nuxos.nixosModules.${name};
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
      environment.systemPackages = [
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
      throw "invalid global auto name: ${name}";
  autos = map mkAuto host.autos;
in
{
  imports = autos;
}
