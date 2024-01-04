{
  config,
  lib,
  ...
}: {
  options.local.services.fail2ban.enable = lib.mkEnableOption "";
  config = lib.mkIf config.local.services.fail2ban.enable {
    services.fail2ban = {
      enable = true;
      bantime-increment = {
        enable = true;
        factor = "16";
      };
    };
  };
}
