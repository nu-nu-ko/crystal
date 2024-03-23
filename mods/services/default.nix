{
  inputs,
  config,
  nuke,
  lib,
  ...
}:
let
  inherit (nuke) mkEnable;
  inherit (lib) mkIf genAttrs mkMerge;
in
{
  imports = [ inputs.snms.nixosModules.default ];

  options.mods.services = {
    fail2ban = mkEnable;
    postgresql = mkEnable;
    openssh = mkEnable;
    prometheus = mkEnable;
    mail = mkEnable;
    synapse = mkEnable;
  };
  config =
    let
      inherit (config.mods.services)
        fail2ban
        postgresql
        openssh
        prometheus
        mail
        synapse
        ;
      inherit (config.networking) domain;
      secret = config.age.secrets;
    in
    {
      age.secrets = mkMerge [
        (mkIf prometheus {
          user_cloud_pom = {
            file = ../../shhh/user_cloud_pom.age;
            owner = "nextcloud-exporter";
          };
        })
        (mkIf synapse {
          synapse_shared = {
            file = ../../shhh/synapse_shared.age;
            owner = "matrix-synapse";
          };
        })
        (mkIf mail (
          genAttrs
            [
              "personal"
              "services"
            ]
            (k: {
              file = ../../shhh + "/${k}_mail.age";
              owner = "dovecot2";
            })
        ))
      ];
      mailserver = mkIf mail {
        enable = mail;
        fqdn = "mail.${domain}";
        domains = [ "${domain}" ];
        loginAccounts = {
          "nuko@${domain}" = {
            hashedPasswordFile = secret.personal.path;
            aliases = [
              "host@${domain}"
              "acme@${domain}"
              "admin@${domain}"
            ];
          };
          "all@${domain}" = {
            hashedPasswordFile = secret.personal.path;
            aliases = [ "@${domain}" ];
          };
          "cloud@${domain}".hashedPasswordFile = secret.services.path;
          "vault@${domain}".hashedPasswordFile = secret.services.path;
        };
        certificateScheme = "acme-nginx";
      };
      services = {
        #dovecot2.sieve.extensions = [ "fileinto" ];
        matrix-synapse = mkIf synapse {
          enable = synapse;
          settings = {
            server_name = domain;
            max_upload_size = "10G";
            url_preview_enabled = true;
            presence.enabled = false;
            enable_metrics = true;
            withJemalloc = true;
            registration_shared_secret_path = config.age.secrets.synapse_shared.path;
            registration_requires_token = true;
            listeners =
              let
                tls = false;
                bind_addresses = [ "127.0.0.1" ];
              in
              [
                {
                  inherit tls bind_addresses;
                  port = 8008;
                  resources = [
                    {
                      compress = true;
                      names = [ "client" ];
                    }
                    {
                      compress = false;
                      names = [ "federation" ];
                    }
                  ];
                  type = "http";
                  x_forwarded = true;
                }
                {
                  inherit tls bind_addresses;
                  port = 9118;
                  type = "metrics";
                  resources = [ ];
                }
              ];
          };
        };
        prometheus = mkIf prometheus {
          enable = prometheus;
          exporters = {
            zfs.enable = true;
            node = {
              enable = true;
              enabledCollectors = [ "systemd" ];
            };
            nextcloud = {
              enable = true;
              username = "nuko";
              passwordFile = secret.user_cloud_pom.path;
              url = "https://cloud.shimeji.cafe";
            };
            nginx.enable = true;
          };
          scrapeConfigs = [
            {
              job_name = "library";
              static_configs = [ { targets = [ "127.0.0.1:9100" ]; } ];
            }
            {
              job_name = "nextcloud";
              static_configs = [ { targets = [ "127.0.0.1:9205" ]; } ];
            }
            {
              job_name = "zfs";
              static_configs = [ { targets = [ "127.0.0.1:9134" ]; } ];
            }
            {
              job_name = "nginx";
              static_configs = [ { targets = [ "127.0.0.1:9113" ]; } ];
            }
            {
              job_name = "synapse";
              metrics_path = "/_synapse/metrics";
              static_configs = [ { targets = [ "127.0.0.1:9118" ]; } ];
            }
          ];
        };
        ### fail2ban
        fail2ban = mkIf fail2ban {
          enable = fail2ban;
          bantime-increment = {
            enable = true;
            factor = "16";
          };
          jails = {
            dovecot.settings = {
              filter = "dovecot[mode=aggressive]";
              maxretry = 3;
            };
            nginx-botsearch.settings = {
              maxretry = 5;
              findtime = 30;
            };
          };
        };
        ### postgresql
        postgresql = {
          enable = postgresql;
        };
        ### openssh
        openssh = mkIf openssh {
          enable = true;
          openFirewall = true;
          settings = {
            PermitRootLogin = "no";
            PasswordAuthentication = false;
            LogLevel = "VERBOSE";
          };
        };
      };
    };
}
