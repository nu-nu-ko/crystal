{ lib, _lib, ... }:
let
  inherit (lib) mkOption listToAttrs types;
  inherit (types) int bool str;
  inherit (_lib) mkEnable setInt setStr;
in
{
  _module.args._lib = {
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
    # like `lib.mkEnableOption` but stupid
    mkEnable = mkOption {
      default = false;
      type = bool;
    };
    # all my web modules just have these options anyway
    mkWebOpt = dns: port: {
      enable = mkEnable;
      dns = setStr dns;
      port = setInt port;
    };
    # how this isnt yet in `lib.` is surprising
    genAttrs' = list: f: listToAttrs (map f list);

    mkAssert = a: [
      {
        assertion = a;
        message = "all web modules require nginx.";
      }
    ];
  };
}
