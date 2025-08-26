{
  inputs,
  config,
  lib,
  flakelight,
  src,
  ...
}:
let
  inherit (builtins)
    attrValues
    getAttr
    hasAttr
    mapAttrs
    pathExists
    ;
  inherit (lib) evalModules mkOption;
  inherit (lib.types)
    int
    lazyAttrsOf
    listOf
    str
    submodule
    ;
  inherit (flakelight) importDir;
  inherit (flakelight.types) nullable;
  getAttrOr =
    name: attrs: value:
    if hasAttr name attrs then getAttr name attrs else value;
  coreModulesDir = modules/core;
  # Builtin nixos/home modules directory
  nixosModulesDir = modules/nixos;
  homeModulesDir = modules/home;
  coreModules = importDir coreModulesDir;
  # Merge builtin nixos/home modules with config modules
  nixosModules = importDir nixosModulesDir // config.nixosModules;
  homeModules = importDir homeModulesDir // config.homeModules;
  hostsDir = config.nixDir + /hosts;
  usersDir = config.nixDir + /users;
  wallpapersDir = ./wallpapers;
  optionsJson = ./data/options.json;
  packagesJson = ./data/packages.json;
  homeOptionsJson = ./data/home-options.json;
  defaultHost = {
    system = "x86_64-linux";
    autos = [
      "gdm"
      "xmonad"
    ];
  };
  nuxos = {
    inherit
      importDir
      nixosModules
      homeModules
      wallpapersDir
      optionsJson
      packagesJson
      homeOptionsJson
      ;
  };
  fromUser =
    username: usercfg:
    let
      userDir = lib.path.append usersDir username;
      userModules = if pathExists userDir then importDir userDir else { };
    in
    {
      system = usercfg.system or "x86_64-linux";
      modules = [
        {
          home = {
            stateVersion = "25.11";
            homeDirectory = usercfg.homeDirectory or ("/home/" + username);
          };
        }
      ] ++ (attrValues userModules);
    };
  fromUsers = users: mapAttrs fromUser users;
  fromHost =
    users': hostname: hostcfg:
    let
      host =
        (evalModules {
          modules = [
            hostOptions
            { config = hostcfg; }
          ];
        }).config;
      users = mapAttrs (
        _: usercfg:
        (evalModules {
          modules = [
            userOptions
            { config = usercfg; }
          ];
        }).config
      ) users';
      hostDir = lib.path.append hostsDir hostname;
      hostModules = if pathExists hostDir then importDir hostDir else { };
    in
    {
      system = host.system;
      specialArgs = {
        inherit
          inputs
          host
          users
          nuxos
          src
          ;
      };
      modules = (attrValues coreModules) ++ (attrValues hostModules);
    };
  fromHosts = hosts: users: mapAttrs (fromHost users) hosts;
  fileSystemOptions = {
    options = {
      device = mkOption {
        type = str;
      };
      fsType = mkOption {
        type = str;
      };
      options = mkOption {
        type = listOf str;
        default = [ "defaults" ];
      };
    };
  };
  userOptions = {
    options = {
      uid = mkOption {
        type = nullable int;
        default = null;
      };
      gid = mkOption {
        type = nullable int;
        default = null;
      };
      description = mkOption {
        type = nullable str;
        default = null;
      };
      email = mkOption {
        type = nullable str;
        default = null;
      };
      autos = mkOption {
        type = listOf str;
        default = [ ];
      };
    };
  };

  hostOptions = {
    options = {
      system = mkOption {
        type = str;
      };
      language = mkOption {
        type = str;
        default = "en_US.UTF-8";
      };
      timezone = mkOption {
        type = str;
        default = "UTC";
      };
      fileSystems = mkOption {
        type = lazyAttrsOf types.fileSystem;
        default = { };
      };
      autos = mkOption {
        type = listOf str;
        default = [ ];
      };
    };
  };

  types = {
    fileSystem = submodule [
      fileSystemOptions
    ];
    user = submodule [
      userOptions
    ];
    host = submodule [
      hostOptions
    ];
  };
in
{
  options = {
    hosts = mkOption {
      type = lazyAttrsOf types.host;
      default = {
        nuxos = defaultHost;
      };
    };
    users = mkOption {
      type = lazyAttrsOf types.user;
      default = {
        nux = {
          description = "Nux User";
        };
      };
    };
  };

  config = {
    nixosConfigurations = fromHosts config.hosts config.users;
    homeConfigurations = fromUsers config.users;
    outputs = {
      inherit nuxos;
      inherit (config) hosts users;
    };
  };
}
