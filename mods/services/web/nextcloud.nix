{
  config,
  pkgs,
  _lib,
  lib,
  ...
}:
{
  options._services.web.nextcloud = _lib.mkWebOpt "cloud" 0;
  config =
    let
      inherit (config._services.web.nextcloud) enable dns;
      inherit (config.networking) domain;
    in
    lib.mkIf enable {
      assertions = _lib.mkAssert config._services.nginx;
      age.secrets =
        lib.genAttrs
          [
            "user_cloud"
            "cloud_env"
          ]
          (k: {
            file = ../../../assets/age + "/${k}.age";
            owner = "nextcloud";
          });
      services.nextcloud = {
        inherit enable;
        package = pkgs.nextcloud28;
        database.createLocally = true;
        configureRedis = true;
        config = {
          adminuser = "nuko";
          adminpassFile = config.age.secrets.user_cloud.path; # only set on setup.
          dbtype = "pgsql";
        };
        phpOptions = {
          "opcache.interned_strings_buffer" = "16";
          "output_buffering" = "off";
        };
        # just the smtp pass.
        secretFile = config.age.secrets.cloud_env.path;
        settings = {
          mail_smtpmode = "smtp";
          mail_sendmailmode = "smtp";
          mail_smtpsecure = "ssl";
          mail_smtphost = "mail.${domain}";
          mail_smtpport = "465";
          mail_smtpauth = 1;
          mail_smtpname = "cloud@${domain}";
          mail_from_address = "cloud";
          mail_domain = domain;
          default_phone_region = "NZ";
          overwriteprotocol = "https";
          trusted_proxies = [ "https://${dns}.${domain}" ];
          trusted_domains = [ "https://${dns}.${domain}" ];
        };
        hostName = "cloud.${domain}";
        nginx.recommendedHttpHeaders = true;
        https = true;
      };
    };
}
