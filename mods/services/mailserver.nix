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
      age.secrets.mail = {
        file = ../../shhh/mail.age;
        owner = "dovecot2";
      };
      mailserver = {
        enable = true;
        fqdn = "mail.${baseDomain}";
        domains = ["${baseDomain}"];

        loginAccounts = {
          "host@${baseDomain}" = {
            hashedPasswordFile = config.age.secrets.mail.path;
            aliases = ["me@${baseDomain}" "acme@${baseDomain}" "admin@${baseDomain}"];
          };
          "nextcloud@${baseDomain}".hashedPasswordFile = config.age.secrets.mail.path;
          #"vaultwarden@${baseDomain}".hashedPasswordFile = config.age.secrets.mail.path;
        };
        certificateScheme = "acme-nginx";
      };
    };
}
