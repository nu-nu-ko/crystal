{ config, pkgs, lib, inputs, ... }: {
  imports = [ "${inputs.qbit}/nixos/modules/services/torrent/qbittorrent.nix" ];
  #### awaiting pr ####
  options.service.web.qbit = lib.mkEnableOption "";
  config = lib.mkIf config.service.web.qbit {
    services = {
      qbittorrent = {
        enable = true;
        openFirewall = true;
        group = "media";
        package = pkgs.qbittorrent-nox.overrideAttrs {
          meta.mainProgram = "qbittorrent-nox";
        };
        serverConfig = {
          LegalNotice.Accepted = true;
          BitTorrent.Session = {
            DefaultSavePath = "/storage/media/torrents/";
            TorrentExportDirectory = "/storage/media/torrents/sources/";
            TempPathEnabled = true;
            TempPath = "/storage/media/torrents/incomplete/";
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
              RootFolder = pkgs.fetchzip {
                url = "https://github.com/VueTorrent/VueTorrent/releases/download/v2.5.0/vuetorrent.zip";
                hash = "sha256-ys9CrbpOPYu8xJsCnqYKyC4IFD/SSAF8j+T+USqvGA8=";
              };
              Username = "nuko";
              Password_PBKDF2 = ''
                "@ByteArray(g+9najSg/RPqxpxPVWLi9g==:TtILo6iFdNBeD0BhYuPtTYSPiP4QLc2M5dJ3Zxen28g9uy+g2Paq5KF1sU5POQF2ItChu1bujpp0ydLy9z7jSQ==)"'';
              ReverseProxySupportEnabled = true;
              TrustedReverseProxiesList = "qbit.${config.service.web.domain}";
            };
            General.Locale = "en";
          };
        };
      };
      nginx.virtualHosts."qbit.${config.service.web.domain}" = {
        forceSSL = true;
        enableACME = true;
        locations."/".proxyPass = "http://localhost:8077";
      };
    };
  };
}
