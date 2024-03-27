{
  inputs,
  config,
  pkgs,
  _lib,
  lib,
  ...
}:
{
  # awaiting 287923 
  imports = [ "${inputs.qbit}/nixos/modules/services/torrent/qbittorrent.nix" ];

  options._services.web.qbittorrent = _lib.mkWebOpt "qbit" 8098;
  config =
    let
      inherit (config._services.web.qbittorrent) enable port dns;
    in
    lib.mkIf enable {
      assertions = _lib.mkAssert config._services.nginx;
      services.qbittorrent = {
        inherit enable;
        group = "media";
        webuiPort = port;
        torrentingPort = 43862;
        openFirewall = enable;
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
              TrustedReverseProxiesList = "${dns}.${config.networking.domain}";
            };
            General.Locale = "en";
          };
        };
      };
    };
}
