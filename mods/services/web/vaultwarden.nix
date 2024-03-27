{
  modulesPath,
  inputs,
  config,
  _lib,
  lib,
  ...
}:
{
  # awaiting 292485
  disabledModules = [ "${modulesPath}/services/security/vaultwarden/default.nix" ];
  imports = [ "${inputs.vault}/nixos/modules/services/security/vaultwarden/default.nix" ];

  options._services.web.vaultwarden = _lib.mkWebOpt "vault" 8092;
  config =
    let
      inherit (config.networking) domain;
      inherit (config._services.web.vaultwarden) port enable;
    in
    lib.mkIf enable {
      assertions = _lib.mkAssert config._services.nginx;
      age.secrets.vault_env = {
        file = ../../../assets/age/vault_env.age;
        owner = "vaultwarden";
      };
      services.vaultwarden = {
        inherit enable;
        config = {
          DOMAIN = "https://vault.${domain}";
          SIGNUPS_ALLOWED = false;
          ROCKET_PORT = port;
          ROCKET_LOG = "critical";
          SMTP_HOST = "mail.${domain}";
          SMPT_PORT = 465;
          SMTP_SECURITY = "starttls";
          SMTP_FROM = "vault@${domain}";
          SMTP_FROM_NAME = "vault.${domain} Vaultwarden server";
          SMTP_USERNAME = "vault@${domain}";
        };
        environmentFile = config.age.secrets.vault_env.path;
      };
    };
}
