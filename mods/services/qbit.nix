{
  config,
  pkgs,
  lib,
  inputs,
  ...
}: {
  imports = [
    "${inputs.qbit}/nixos/modules/services/torrent/qbittorrent.nix"
  ];
  options.local.services.web.qbit.enable = lib.mkEnableOption "";
  config = let
    domain = "qbit.${config.local.services.web.domain}";
    vueTorrent = pkgs.buildNpmPackage rec {
        pname = "VueTorrent";
        version = "2.4.0";
        src = pkgs.fetchFromGitHub {
            owner = "WDaan";
            repo = pname;
            rev = "v${version}";
            hash = "sha256-zz7J1m7z4nkk3ju1Y1j7GKZgp17ZZ0aqKJRAvVGemsg=";
        };
        npmDepsHash = "sha256-EhMjyhEhItUFS0adPInvgu0mF+S/Gzh79ZolnDQ1cC4=";
        npmPackFlags = [ "--ignore-scripts" ];
    };
  in lib.mkIf config.local.services.web.qbit.enable {
    services = {
      qbittorrent = {
        enable = true;
        profileDir = "/storage/volumes/qbit";
        package = (pkgs.qbittorrent-nox.overrideAttrs { meta.mainProgram = "qbittorrent-nox"; });
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
              Password_PBKDF2 = "\"@ByteArray(M0FhBucrHYySuTMNFuFN4A==:3T/dU2kxC2Z6k74CMNFr09wEULEmYDCCnaiVsSV4yChKalsyEGHOMu38sJZiahQeg7LmBVbTJqSPcY/1cGzicw==)\"";
              ReverseProxySupportEnabled = true;
              TrustedReverseProxiesList = "qbit.nuko.city";
              AlternativeUIEnabled = true;
              #RootFolder = (toString vueTorrent);
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
        allowedUDPPorts = [8077 42862];
    };
  };
}
