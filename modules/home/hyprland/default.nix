{nuxos, ...}: let
  inherit (builtins) attrValues;
  inherit (nuxos) importDir;
in {
  imports = attrValues (importDir ./.);
}
