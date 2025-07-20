{
  lib,
  pkgs,
  options,
  nuxos,
  host,
  ...
}:
let
  inherit (builtins) groupBy hasAttr;
  inherit (lib) mkMerge;
  isModule = name: hasAttr name nuxos.nixosModules;
  isService = name: hasAttr name options.services && hasAttr "enable" options.services.${name};
  isProgram = name: hasAttr name options.programs;
  mkModule = name: nuxos.nixosModules.${name};
  mkService = name: {
    services.${name}.enable = true;
  };
  mkProgram = name: {
    programs.${name}.enable = true;
  };
  mkPackage = name: {
    environment.systemPackages = [
      pkgs.${name} or pkgs.kdePackages.${name} or pkgs.xfce.${name} or pkgs.haskellPackages.${name}
    ];
  };
  # FIXME: Must separate modules from others, modules will go in `imports`,
  # while others go in `config`. If mix them together, it will result in
  # infinitive recursion error. But the same does not result in error in
  # home-manager.nix.
  groupType = name: if isModule name then "modules" else "others";
  groups = groupBy groupType host.autos;
  modules = map mkModule groups.modules or [ ];
  others = map mkOther groups.others or [ ];
  mkOther =
    name:
    if isService name then
      mkService name
    else if isProgram name then
      mkProgram name
    else
      mkPackage name;
in
{
  imports = modules;
  config = mkMerge others;
}
