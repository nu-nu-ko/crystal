{
  config,
  pkgs,
  lib,
  ...
}: {
  options.local.services.web.qbit.enable = lib.mkEnableOption "";
  config = let
    domain = "qbit.${config.local.services.web.domain}";
  in lib.mkIf config.local.services.web.qbit.enable {
    services = {
      qbittorrent = {
        enable = true;
        package = (pkgs.qbittorrent-nox.overrideAttrs { meta.mainProgram = "qbittorrent-nox"; });
        serverConfig = {
          LegalNotice = {
            Accepted = true;
          };
          Preferences = {
            WebUI = {
              Port = 8077;
            };
          };
        };
      };
      nginx.virtualHosts."${domain}" = {
        forceSSL = true;
        enableACME = true;
        locations."/".proxyPass = "http://127.0.0.1:8080";
      };
    };
    networking.firewall = {
        allowedTCPPorts = [8080];
        allowedUDPPorts = [8080];
    };
  };
}
