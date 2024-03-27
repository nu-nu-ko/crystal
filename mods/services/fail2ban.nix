{
  config,
  _lib,
  lib,
  ...
}:
{
  options._services.fail2ban = _lib.mkEnable;
  config.services.fail2ban =
    let
      inherit (lib) mkIf;
      inherit (config._services) fail2ban mailServer nginx;
    in
    mkIf fail2ban {
      enable = true;
      bantime-increment = {
        enable = true;
        factor = "16";
      };
      jails = {
        dovecot.settings = mkIf mailServer {
          filter = "dovecot[mode=aggressive]";
          maxretry = 3;
        };
        nginx-botsearch.settings = mkIf nginx {
          maxretry = 5;
          findtime = 30;
        };
      };
    };
}
