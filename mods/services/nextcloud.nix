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
      #### STATEFUL CRAP WARNING ####
      # this module only sets the service up. all config is done in the client
      # the postgres table used is apart of this, trying to put in a volume seems impractical.
      # thankfully actual user data is stored in the nextcloud volume.
      age.secrets.user_cloud = {
        file = ../../shhh/user_cloud.age;
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
            adminuser = "nuko";
            adminpassFile = config.age.secrets.user_cloud.path;
            dbtype = "pgsql";
            dbhost = "/run/postgresql";
            dbname = "nextcloud";
          };
          extraOptions = {
            overwriteprotocol = "https";
            trusted_proxies = ["https://${domain}"];
            trusted_domains = ["https://${domain}"];
            default_phone_region = "NZ";
          };
          nginx.recommendedHttpHeaders = true;
          https = true;
          phpOptions = {
            "opcache.interned_strings_buffer" = "16";
            "output_buffering" = "off";
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
