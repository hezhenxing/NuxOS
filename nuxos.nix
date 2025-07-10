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
  # Builtin nixos/home/profile modules directory
  nixosModulesDir = modules/nixos;
  homeModulesDir = modules/home;
  profilesDir = modules/profiles;
  coreModules = importDir coreModulesDir;
  # Merge builtin nixos/home/profile modules with config modules
  nixosModules = importDir nixosModulesDir // config.nixosModules;
  homeModules = importDir homeModulesDir // config.homeModules;
  profiles = importDir profilesDir // config.profiles;
  hostsDir = config.nixDir + /hosts;
  usersDir = config.nixDir + /users;
  wallpapersDir = ./wallpapers;
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
      profiles
      wallpapersDir
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
    profiles: users': hostname: hostcfg:
    let
      profileName = hostcfg.profile or "";
      profile' = getAttrOr profileName profiles { };
      profile = fixProfile profiles profile';
      fixProfile =
        profiles: profile:
        let
          baseName = profile.base or "";
          base = getAttrOr baseName profiles { };
          mergeProfile =
            base: profile:
            let
              mergedHost =
                (evalModules {
                  modules = [
                    hostProfileOptions
                    { config = base.host or { }; }
                    { config = profile.host or { }; }
                  ];
                }).config;
              mergedUser =
                (evalModules {
                  modules = [
                    userProfileOptions
                    { config = base.user or { }; }
                    { config = profile.user or { }; }
                  ];
                }).config;
            in
            {
              host = mergedHost;
              user = mergedUser;
            };
        in
        if base == { } then profile else mergeProfile (fixProfile profiles base) profile;
      host =
        (evalModules {
          modules = [
            hostOptions
            { config = hostcfg; }
            { config = profile.host or { }; }
          ];
        }).config;
      users = mapAttrs (
        _: usercfg:
        (evalModules {
          modules = [
            userOptions
            { config = usercfg; }
            { config = profile.user or { }; }
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
  fromHosts =
    profiles: hosts: users:
    mapAttrs (fromHost profiles users) hosts;
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
      profile = mkOption {
        type = str;
        default = "";
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

  hostProfileOptions = {
    options = {
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

  userProfileOptions = {
    options = {
      autos = mkOption {
        type = listOf str;
        default = [ ];
      };
    };
  };

  profileOptions = {
    options = {
      base = mkOption {
        type = str;
        default = "";
      };
      host = mkOption {
        type = types.hostProfile;
        default = { };
      };
      user = mkOption {
        type = types.userProfile;
        default = { };
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
    userProfile = submodule [
      userProfileOptions
    ];
    hostProfile = submodule [
      hostProfileOptions
    ];
    profile = submodule [
      profileOptions
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
    profiles = mkOption {
      type = lazyAttrsOf types.profile;
      default = { };
    };
  };

  config = {
    nixosConfigurations = fromHosts profiles config.hosts config.users;
    homeConfigurations = fromUsers config.users;
    outputs = {
      inherit nuxos;
      inherit (config) hosts users;
    };
  };
}
