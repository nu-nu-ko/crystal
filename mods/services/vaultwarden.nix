{
  config,
  lib,
  ...
}: {
  options.local.services.web.vaultwarden.enable = lib.mkEnableOption "";
  config = let
    domain = "vault.${config.local.services.web.domain}";
  in
    lib.mkIf config.local.services.web.vaultwarden.enable {
      services = {
        vaultwarden = {
          enable = true;
          config = {
            DOMAIN = "https://${domain}";
            SIGNUPS_ALLOWED = false;
            ROCKET_ADDRESS = "127.0.0.1";
            ROCKET_PORT = 8222;
            ROCKET_LOG = "critical";

            # disabled as theres no nice/simple way to supply the SMTP_PASSWORD secret.
            # can always just reenable privately if a recovery email is needed. jank :(
            #SMTP_HOST = "mail.nuko.city";
            #SMPT_PORT = 465;
            #SMTP_SSL = true;
            #SMTP_FROM = "vaultwarden@nuko.city";
            #SMTP_FROM_NAME = "vault.nuko.city Vaultwarden server";
            #SMTP_USERNAME = "vaultwarden@nuko.city";
            #SMTP_PASSWORD = "";
          };
          backupDir = "/storage/volumes/vault";
        };
        nginx.virtualHosts."${domain}" = {
          forceSSL = true;
          enableACME = true;
          locations."/" = {
            proxyPass = "http://127.0.0.1:${toString config.services.vaultwarden.config.ROCKET_PORT}";
            extraConfig = "proxy_pass_header Authorization;";
          };
        };
      };
    };
}
