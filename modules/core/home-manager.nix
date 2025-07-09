{
  inputs,
  nuxos,
  pkgs,
  options,
  hostname,
  host,
  users,
  ...
}: let
  inherit (builtins) hasAttr mapAttrs;
  isModule = name:
    hasAttr name nuxos.homeModules;
  isService = name:
    hasAttr name options.services
    && hasAttr "enable" options.services.${name};
  isProgram = name:
    hasAttr name options.programs;
  mkModule = name: nuxos.homeModules.${name};
  mkService = name: {services.${name}.enable = true;};
  mkProgram = name: {programs.${name}.enable = true;};
  mkPackage = name: {home.packages = [pkgs.${name}];};
  mkAuto = name:
    if isModule name
    then mkModule name
    else if isService name
    then mkService name
    else if isProgram name
    then mkProgram name
    else mkPackage name;
  hmUser = username: usercfg: let
    autos = map mkAuto usercfg.autos;
  in {
    home = {
      inherit username;
      homeDirectory = "/home/${username}";
    };
    imports = autos;
  };
  hmUsers = mapAttrs hmUser users;
in {
  imports = [
    inputs.home-manager.nixosModules.home-manager
  ];

  home-manager = {
    useUserPackages = true;
    useGlobalPkgs = true;
    extraSpecialArgs = {
      inherit inputs nuxos hostname host users;
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
