{
  config,
  _lib,
  lib,
  ...
}:
{
  options._services.openssh = _lib.mkEnable;
  config.services.openssh = lib.mkIf config._services.openssh {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
      LogLevel = "VERBOSE";
    };
  };
}
