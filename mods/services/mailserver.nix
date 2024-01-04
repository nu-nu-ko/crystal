{
  config,
  lib,
  ...
}: {
  options.local.services.mailserver.enable = lib.mkEnableOption "";
  config = let
    baseDomain = "${config.local.services.web.domain}";
  in
    lib.mkIf config.local.services.mailserver.enable {
      age.secrets = {
        personal = {
          file = ../../shhh/personal_mail.age;
          owner = "dovecot2";
        };
        services = {
          file = ../../shhh/services_mail.age;
          owner = "dovecot2";
        };
      };
      mailserver = {
        enable = true;
        fqdn = "mail.${baseDomain}";
        domains = ["${baseDomain}"];

        loginAccounts = {
          "host@${baseDomain}" = {
            hashedPasswordFile = config.age.secrets.personal.path;
            aliases = ["me@${baseDomain}" "acme@${baseDomain}" "admin@${baseDomain}"];
          };
          "cloud@${baseDomain}".hashedPasswordFile = config.age.secrets.services.path;
          #"vault@${baseDomain}".hashedPasswordFile = config.age.secrets.services.path;
        };
        certificateScheme = "acme-nginx";
      };
    };
}
