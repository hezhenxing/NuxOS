{
  lib,
  pkgs,
  host,
  ...
}:
let
  inherit (lib)
    substring
    hasPrefix
    ;
  lang = substring 0 5 host.language;
  commonAddons = with pkgs; [
    fcitx5-gtk
    fcitx5-nord
  ];
  languageAddons = {
    zh_CN = with pkgs; [
      fcitx5-chinese-addons
    ];
  };
  addons = commonAddons ++ (languageAddons.${lang} or [ ]);
in
{
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5 = {
      inherit addons;
      waylandFrontend = true;
    };
  };
  environment.variables = {
    XMODIFIERS = "@im=fcitx";
    GTK_IM_MODULE = "fcitx";
    QT_IM_MODULE = "fcitx";
    GLFW_IM_MODULE = "ibus"; # required by kitty
  };
}
