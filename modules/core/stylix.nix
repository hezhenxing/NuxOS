{
  inputs,
  nuxos,
  pkgs,
  ...
}: {
  imports = [
    inputs.stylix.nixosModules.stylix
  ];
  stylix = {
    enable = true;
    image = nuxos.wallpapersDir + /Night-Mountains-Summer.jpg;
    polarity = "dark";
    cursor = {
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Ice";
      size = 24;
    };
  };
}
