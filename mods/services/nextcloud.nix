{
  config,
  pkgs,
  lib,
  ...
}: {
  options.local.services.web.nextcloud.enable = lib.mkEnableOption "";
  config = let
    domain = "cloud.${config.local.services.web.domain}";
  in
    lib.mkIf config.local.services.web.nextcloud.enable {
      age.secrets.next = {
        file = ../../shhh/next.age;
        owner = "nextcloud";
      };
      services = {
        nextcloud = {
          enable = true;
          package = pkgs.nextcloud28;
          hostName = domain;
          home = "/storage/volumes/nextcloud";
          autoUpdateApps.enable = true;
          configureRedis = true;
          config = {
            overwriteProtocol = "https";
            extraTrustedDomains = ["https://${domain}"];
            trustedProxies = ["https://${domain}"];
            adminuser = "nuko";
            adminpassFile = config.age.secrets.next.path;
            dbtype = "pgsql";
            dbhost = "/run/postgresql";
            dbname = "nextcloud";
            defaultPhoneRegion = "NZ";
          };
          nginx.recommendedHttpHeaders = true;
          https = true;
          phpOptions = {
            "opcache.interned_strings_buffer" = "16";
          };
        };
        postgresql = {
          enable = true;
          ensureDatabases = [config.services.nextcloud.config.dbname];
          ensureUsers = [
            {
              name = config.services.nextcloud.config.dbuser;
              ensureDBOwnership = true;
            }
          ];
        };
        nginx.virtualHosts."${domain}" = {
          forceSSL = true;
          enableACME = true;
          http2 = true;
        };
      };
      systemd.services."nextcloud-setup" = {
        requires = ["postgresql.service"];
        after = ["postgresql.service"];
      };
    };
}
