{
  config,
  lib,
  ...
}: {
  options.local.services.web.forgejo.enable = lib.mkEnableOption "";
  config = let
    domain = "tea.${config.local.services.web.domain}";
  in
    lib.mkIf config.local.services.web.forgejo.enable {
      services = {
        forgejo = {
          enable = true;
          settings = {
            service.DISABLE_REGISTRATION = false;
            session.COOKIE_SECURE = true;
            server = {
              ROOT_URL = "https://${domain}/";
              DOMAIN = "${domain}";
              HTTP_PORT = 3001;
              LANDING_PAGE = "/explore/repos";
            };
          };
          stateDir = "/storage/volumes/forgejo";
        };
        nginx.virtualHosts."${domain}" = {
          forceSSL = true;
          enableACME = true;
          locations."/".proxyPass = "http://127.0.0.1:${toString config.services.forgejo.settings.server.HTTP_PORT}";
        };
      };
    };
}
