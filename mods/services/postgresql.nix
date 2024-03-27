{ config, _lib, ... }:
{
  options._services.postgresql = _lib.mkEnable;
  config.services.postgresql.enable = config._services.postgresql;
}
