{ lib, nuke, ... }:
let
  inherit (lib) mkOption listToAttrs;
  inherit (lib.types) int bool str;
  inherit (nuke) mkEnable setInt setStr;
in
{
  _module.args.nuke = {
    setInt =
      dint:
      mkOption {
        default = dint;
        type = int;
        readOnly = true;
      };
    setStr =
      dstr:
      mkOption {
        default = dstr;
        type = str;
        readOnly = true;
      };

    # like `lib.mkEnableOption` but stupid.
    mkEnable = mkOption {
      default = false;
      type = bool;
    };
    # all my web modules just have these options anyway.
    mkWebOpt = dns: port: {
      enable = mkEnable;
      dns = setStr dns;
      port = setInt port;
    };

    # how this isnt yet in `lib.` is surprising..
    genAttrs' = list: f: listToAttrs (map f list);
  };
}
