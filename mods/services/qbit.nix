{
  config,
  pkgs,
  lib,
  inputs,
  ...
}: {
  #### awaiting pr; openFirewall & webui path inclusion are borked.
  imports = [
    "${inputs.qbit}/nixos/modules/services/torrent/qbittorrent.nix"
  ];
  ####
  options.local.services.web.qbit.enable = lib.mkEnableOption "";
  config = let
    domain = "qbit.${config.local.services.web.domain}";
  in
    lib.mkIf config.local.services.web.qbit.enable {
      services = {
        qbittorrent = {
          enable = true;
          profileDir = "/storage/volumes/qbit";
          package = pkgs.qbittorrent-nox.overrideAttrs {meta.mainProgram = "qbittorrent-nox";};
          extraPackages = [];
          #openFirewall = true;
          serverConfig = {
            LegalNotice = {
              Accepted = true;
            };
            BitTorrent.Session = {
              Port = 43862;
              DefaultSavePath = "/storage/torrents/";
              TorrentExportDirectory = "/storage/torrents/sources/";
              TempPathEnabled = true;
              TempPath = "/storage/torrents/incomplete/";
              QueueingSystemEnabled = true;
              GlobalMaxInactiveSeedingMinutes = 43800;
              GlobalMaxSeedingMinutes = 10080;
              GlobalMaxRatio = 2;
              MaxActiveCheckingTorrents = 2;
              MaxActiveDownloads = 5;
              MaxActiveUploads = 15;
              MaxActiveTorrents = 20;
              IgnoreSlowTorrentsForQueueing = true;
              SlowTorrentsDownloadRate = 20; #kbps
              SlowTorrentsUploadRate = 20; # kbps
              MaxConnections = 600;
              MaxUploads = 200;
            };
            Preferences = {
              WebUI = {
                Port = 8077;
                Username = "nuko";
                Password_PBKDF2 = "\"@ByteArray(g+9najSg/RPqxpxPVWLi9g==:TtILo6iFdNBeD0BhYuPtTYSPiP4QLc2M5dJ3Zxen28g9uy+g2Paq5KF1sU5POQF2ItChu1bujpp0ydLy9z7jSQ==)\"";
                ReverseProxySupportEnabled = true;
                TrustedReverseProxiesList = "qbit.nuko.city";
                AlternativeUIEnabled = true;
                RootFolder = "/storage/volumes/qbit/vuetorrent/";
              };
              General.Locale = "en";
            };
          };
        };
        nginx.virtualHosts."${domain}" = {
          forceSSL = true;
          enableACME = true;
          locations."/".proxyPass = "http://127.0.0.1:8077";
        };
      };
      networking.firewall = {
        allowedTCPPorts = [8077 43862];
        allowedUDPPorts = [42862];
      };
    };
}
