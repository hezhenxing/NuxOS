{
  pkgs,
  host,
  users,
  ...
}: let
  inherit (builtins) attrValues mapAttrs;
  mkModule = username: usercfg: {
    users = {
      groups.${username} = {
        gid = usercfg.gid or usercfg.uid or null;
      };
      users.${username} = {
        isNormalUser = true;
        uid = usercfg.uid or null;
        description = usercfg.description or username;
        group = username;
        extraGroups = [
          "networkmanager"
          "wheel"
        ];
        shell = pkgs.zsh;
        ignoreShellProgramCheck = true;
        initialPassword = "nuxos";
      };
    };
    nix.settings = {
      allowed-users = [username];
      trusted-users = [username];
    };
    security.sudo.extraRules = [
      {
        users = [username];
        commands = [
          {
            command = "ALL";
            options = ["NOPASSWD"];
          }
        ];
      }
    ];
  };
  modules = attrValues (mapAttrs mkModule users);
in {
  imports = modules;
  users.mutableUsers = true;
}
