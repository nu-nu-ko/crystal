{
  config,
  _lib,
  lib,
  ...
}:
{
  options._services.web.komga = _lib.mkWebOpt "komga" 8097;
  config =
    let
      inherit (config._services.web.komga) enable port;
    in
    lib.mkIf enable {
      assertions = _lib.mkAssert config._services.nginx;
      services.komga = {
        inherit enable port;
        group = "media";
      };
    };
}
