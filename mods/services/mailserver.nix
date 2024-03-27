{
  inputs,
  config,
  _lib,
  lib,
  ...
}:
{
  imports = [ inputs.snms.nixosModules.default ];
  options._services.mailServer = _lib.mkEnable;
  config =
    let
      inherit (config._services) mailServer;
      inherit (config.networking) domain;
      ap = config.age.secrets;
    in
    lib.mkIf mailServer {
      age.secrets =
        lib.genAttrs
          [
            "personal"
            "services"
          ]
          (k: {
            file = ../../assets/age + "/${k}_mail.age";
            owner = "dovecot2";
          });
      mailserver = {
        enable = true;
        fqdn = "mail." + domain;
        domains = [ domain ];
        loginAccounts = {
          "nuko@${domain}" = {
            hashedPasswordFile = ap.personal.path;
            aliases = [
              "host@${domain}"
              "acme@${domain}"
              "admin@${domain}"
              "postmaster@${domain}"
              "abuse@${domain}"
            ];
          };
          "all@${domain}" = {
            hashedPasswordFile = ap.personal.path;
            aliases = [ "@${domain}" ];
          };
          "cloud@${domain}".hashedPasswordFile = ap.services.path;
          "vault@${domain}".hashedPasswordFile = ap.services.path;
        };
        enableImap = false;
        enableSubmission = false;
        localDnsResolver = false;
      };
    };
}
