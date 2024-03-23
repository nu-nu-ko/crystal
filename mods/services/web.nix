{
  modulesPath,
  inputs,
  config,
  pkgs,
  nuke,
  lib,
  ...
}:
let
  inherit (nuke) mkWebOpt;
  inherit (lib) mkIf genAttrs mkMerge;
in
{
  # awaiting PR's 288687(navi) 292485(vault) 287923(qbit)
  disabledModules = [
    "${modulesPath}/services/security/vaultwarden/default.nix"
    "${modulesPath}/services/audio/navidrome.nix"
  ];
  imports =
    let
      inherit (inputs) navi vault qbit;
      nms = "/nixos/modules/services/";
    in
    [
      "${vault}${nms}security/vaultwarden/default.nix"
      "${navi}${nms}audio/navidrome.nix"
      "${qbit}${nms}torrent/qbittorrent.nix"
    ];

  options.mods.services.web = {
    vaultwarden = mkWebOpt "vault" 8092;
    navidrome = mkWebOpt "navi" 8093;
    grafana = mkWebOpt "ana" 8094;
    forgejo = mkWebOpt "tea" 8095;
    jellyfin = mkWebOpt "jelly" 8096;
    komga = mkWebOpt "komga" 8097;
    qbittorrent = mkWebOpt "qbit" 8098;
    nextcloud = mkWebOpt "cloud" 0;
  };
  config =
    let
      inherit (config.mods.services.web)
        komga
        navidrome
        jellyfin
        forgejo
        vaultwarden
        nextcloud
        qbittorrent
        grafana
        ;
      inherit (config.networking) domain;
      group = "media";
      secret = config.age.secrets;
    in
    {
      ### secrets
      age.secrets = mkMerge [
        (mkIf vaultwarden.enable {
          vault_env = {
            file = ../../shhh/vault_env.age;
            owner = "vaultwarden";
          };
        })
        (mkIf nextcloud.enable (
          genAttrs
            [
              "user_cloud"
              "cloud_env"
            ]
            (k: {
              file = ../../shhh + "/${k}.age";
              owner = "nextcloud";
            })
        ))
      ];
      ### service config
      services = {

        grafana = mkIf grafana.enable {
          inherit (grafana) enable;
          settings.server = {
            http_addr = "127.0.0.1";
            http_port = grafana.port;
            domain = "${grafana.dns}.${domain}";
          };
        };

        komga = mkIf komga.enable {
          inherit (komga) enable port;
          inherit group;
        };

        navidrome = mkIf navidrome.enable {
          inherit (navidrome) enable;
          inherit group;
          package = inputs.navi.legacyPackages.${pkgs.system}.navidrome;
          settings = {
            MusicFolder = "/storage/media/Music";
            CacheFolder = "/var/cache/navidrome";
            EnableDownloads = true;
            EnableSharing = true;
            Port = navidrome.port;
          };
        };

        jellyfin = mkIf jellyfin.enable {
          inherit (jellyfin) enable;
          inherit group;
        };

        forgejo = mkIf forgejo.enable {
          inherit (forgejo) enable;
          settings = {
            service.DISABLE_REGISTRATION = true;
            session.COOKIE_SECURE = true;
            server = {
              ROOT_URL = "https://tea.${domain}/";
              DOMAIN = "tea.${domain}";
              HTTP_PORT = forgejo.port;
              LANDING_PAGE = "/explore/repos";
            };
            other.SHOW_FOOTER_VERSION = false;
            DEFAULT.APP_NAME = "gitea";
            "ui.meta".AUTHOR = "gitea";
          };
        };

        vaultwarden = mkIf vaultwarden.enable {
          inherit (vaultwarden) enable;
          config = {
            DOMAIN = "https://vault.${domain}";
            SIGNUPS_ALLOWED = false;
            ROCKET_PORT = vaultwarden.port;
            ROCKET_LOG = "critical";
            SMTP_HOST = "mail.${domain}";
            SMPT_PORT = 465;
            SMTP_SECURITY = "starttls";
            SMTP_FROM = "vault@${domain}";
            SMTP_FROM_NAME = "vault.${domain} Vaultwarden server";
            SMTP_USERNAME = "vault@${domain}";
          };
          environmentFile = secret.vault_env.path;
        };

        nextcloud = mkIf nextcloud.enable {
          inherit (nextcloud) enable;
          package = pkgs.nextcloud28;
          database.createLocally = true;
          configureRedis = true;
          config = {
            adminuser = "nuko";
            adminpassFile = secret.user_cloud.path; # only set on setup.
            dbtype = "pgsql";
          };
          phpOptions = {
            "opcache.interned_strings_buffer" = "16";
            "output_buffering" = "off";
          };
          # just the smtp pass.
          secretFile = secret.cloud_env.path;
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
            trusted_proxies = [ "https://${nextcloud.dns}.${domain}" ];
            trusted_domains = [ "https://${nextcloud.dns}.${domain}" ];
          };
          hostName = "cloud.${domain}";
          nginx.recommendedHttpHeaders = true;
          https = true;
        };

        qbittorrent = mkIf qbittorrent.enable {
          inherit (qbittorrent) enable;
          inherit group;
          webuiPort = qbittorrent.port;
          torrentingPort = 43862;
          openFirewall = qbittorrent.enable;
          serverConfig = {
            LegalNotice.Accepted = true;
            BitTorrent.Session =
              let
                basePath = "/storage/media/torrents/";
              in
              {
                TempPathEnabled = true;
                DefaultSavePath = basePath;
                TempPath = basePath + "incomplete/";
                TorrentExportDirectory = basePath + "sources/";
                QueueingSystemEnabled = true;
                GlobalMaxInactiveSeedingMinutes = 43800;
                GlobalMaxSeedingMinutes = 10080;
                GlobalMaxRatio = 2;
                MaxActiveCheckingTorrents = 2;
                MaxActiveDownloads = 5;
                MaxActiveUploads = 15;
                MaxActiveTorrents = 20;
                IgnoreSlowTorrentsForQueueing = true;
                SlowTorrentsDownloadRate = 30; # kbps
                SlowTorrentsUploadRate = 30; # kbps
                MaxConnections = 600;
                MaxUploads = 200;
              };
            Preferences = {
              WebUI = {
                AlternativeUIEnabled = true;
                RootFolder = pkgs.fetchFromGitHub {
                  owner = "VueTorrent";
                  repo = "VueTorrent";
                  rev = "v2.7.1";
                  hash = "sha256-ZkeDhXDBjakTmJYN9LZtSRMSkaySt1MhS9QDEujBdYI=";
                };
                Username = "nuko";
                Password_PBKDF2 = ''"@ByteArray(g+9najSg/RPqxpxPVWLi9g==:TtILo6iFdNBeD0BhYuPtTYSPiP4QLc2M5dJ3Zxen28g9uy+g2Paq5KF1sU5POQF2ItChu1bujpp0ydLy9z7jSQ==)"'';
                ReverseProxySupportEnabled = true;
                TrustedReverseProxiesList = "${qbittorrent.dns}.${domain}";
              };
              General.Locale = "en";
            };
          };
        };
      };
      systemd.services = {
        jellyfin.serviceConfig = mkIf jellyfin.enable {
          # hardening which isnt appropriate for upstream.
          DeviceAllow = [ "/dev/dri/renderD128" ];
          ProtectSystem = "strict";
          ProtectHome = "yes";
          ReadWritePaths = [
            "/var/lib/jellyfin"
            "/var/cache/jellyfin"
            "/storage/media"
          ];
          # these options seem reasonable for upstream but likely not worth a PR
          ProtectClock = true;
          ProtectProc = "invisible";
          ProcSubset = "pid";
          CapabilityBoundingSet = "";
        };
      };
      # video hardware accel setup
      boot.kernelParams = mkIf jellyfin.enable [ "i915.enable_guc=2" ];
      hardware.opengl = mkIf jellyfin.enable {
        inherit (jellyfin) enable;
        extraPackages = [
          pkgs.intel-media-driver
          pkgs.intel-compute-runtime
        ];
      };
    };
}
