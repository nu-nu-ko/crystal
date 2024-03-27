{
  config,
  _lib,
  lib,
  ...
}:
{
  options._services.web.forgejo = _lib.mkWebOpt "tea" 8095;
  config =
    let
      inherit (config._services.web.forgejo) enable port;
      inherit (config.networking) domain;
    in
    lib.mkIf enable {
      assertions = _lib.mkAssert config._services.nginx;
      services.forgejo = {
        inherit enable;
        settings = {
          service.DISABLE_REGISTRATION = true;
          session.COOKIE_SECURE = true;
          server = {
            ROOT_URL = "https://tea.${domain}/";
            DOMAIN = "tea.${domain}";
            HTTP_PORT = port;
            LANDING_PAGE = "/explore/repos";
          };
          other.SHOW_FOOTER_VERSION = false;
          DEFAULT.APP_NAME = "gitea";
          "ui.meta".AUTHOR = "gitea";
        };
      };
    };
}
