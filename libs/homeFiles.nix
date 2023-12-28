# originally written by lv.cha on discord, ive sinced mangled it a tad.
{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (builtins) replaceStrings;
  inherit (lib.attrsets) mapAttrsToList;
  inherit (lib.lists) flatten;
  inherit (lib.modules) mkIf mkDefault mkDerivedConfig;
  inherit (lib.options) mkOption;
  inherit (lib.types) attrsOf lines nullOr path str submodule;
  _tmpfileType = prefix:
    attrsOf (submodule ({
      config,
      options,
      name,
      ...
    }: {
      options = {
        source = mkOption {type = path;};
        target = mkOption {type = str;};
        text = mkOption {
          default = null;
          type = nullOr lines;
        };
      };
      config = {
        source = mkIf (config.text != null) (mkDerivedConfig options.text (pkgs.writeText "xdg-${prefix}-${replaceStrings ["/"] ["-"] name}"));
        target = mkDefault name;
      };
    }));
in {
  options = {
    home.file = mkOption {
      default = {};
      type = _tmpfileType "homeFile";
    };
  };
  config.systemd.user.tmpfiles.users.main.rules = let
    _tmpStr = prefix: _: file: "L+ '${prefix}/${file.target}' - - - - ${file.source}";
  in
    flatten [
      (mapAttrsToList (_tmpStr "%h") config.home.file)
    ];
}
