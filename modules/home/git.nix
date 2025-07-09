{
  config,
  hostname,
  host,
  users,
  ...
}:
let
  inherit (config.home) username;
  user = users.${username};
in
{
  programs.git = {
    enable = true;
    userName = user.description or username;
    userEmail = user.email or "${username}@${hostname}";
    extraConfig = {
      init = {
        defaultBranch = "main";
      };
    };
  };
}
