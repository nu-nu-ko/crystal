{
  config,
  pkgs,
  lib,
  ...
}:
let
  inherit (lib) mkOption;
  _tmpfileType =
    let
      inherit (builtins) replaceStrings;
      inherit (lib)
        mkIf
        mkDerivedConfig
        mkDefault
        types
        ;
      inherit (types)
        attrsOf
        lines
        nullOr
        path
        str
        submodule
        ;
    in
    prefix:
    attrsOf (
      submodule (
        {
          config,
          options,
          name,
          ...
        }:
        {
          options = {
            source = mkOption { type = path; };
            target = mkOption { type = str; };
            text = mkOption {
              default = null;
              type = nullOr lines;
            };
          };
          config = {
            source = mkIf (config.text != null) (
              mkDerivedConfig options.text (pkgs.writeText "xdg-${prefix}-${replaceStrings [ "/" ] [ "-" ] name}")
            );
            target = mkDefault name;
          };
        }
      )
    );
in
{
  options._homeFile = mkOption {
    default = { };
    type = _tmpfileType "homeFile";
  };
  config.systemd.user.tmpfiles.users.main.rules =
    let
      inherit (lib) mapAttrsToList flatten;
      _tmpStr =
        prefix: _: file:
        "L+ '${prefix}/${file.target}' - - - - ${file.source}";
    in
    flatten [ (mapAttrsToList (_tmpStr "%h") config._homeFile) ];
}
