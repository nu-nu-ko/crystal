{
  config,
  pkgs,
  nuke,
  lib,
  ...
}:
let
  inherit (lib) mkIf;
  inherit (nuke) genAttrs' mkEnable;
  inherit (config.networking) domain;
  cfg = config.mods.services.web;
in
{
  options.mods.services.web.nginx.enable = mkEnable;
  config = mkIf cfg.nginx.enable {
    services.nginx = {
      inherit (cfg.nginx) enable;
      virtualHosts =
        let
          forceSSL = true;
          enableACME = true;

          genHosts =
            list:
            genAttrs' list (
              x:
              let
                inherit (cfg.${x}) enable dns port;
              in
              {
                name = "${dns}.${domain}";
                value = ({
                  locations."/".proxyPass = mkIf enable "http://localhost:${toString port}";
                  inherit forceSSL enableACME;
                });
              }
            );
        in
        genHosts [
          "forgejo"
          "grafana"
          "vaultwarden"
          "navidrome"
          "qbittorrent"
          "komga"
          "jellyfin"
        ]
        // {
          # these two could be better but likey gonna replace both later on..
          "wires.${domain}" = {
            root = "/storage/web/wires";
            inherit forceSSL enableACME;
          };
          # doesnt have a port value so the generator will misconfigure this.
          "cloud.${domain}" = {
            inherit forceSSL enableACME;
          };
          # just needs a lil extra config ontop of the generator
          "vault.${domain}".locations."/".extraConfig = "proxy_pass_header Authorization;";
          # obv could not be generated lmao
          "matrix.${domain}" = {
            inherit forceSSL enableACME;
            locations = {
              "/_matrix".proxyPass = "http://127.0.0.1:8008";
              "/_synapse".proxyPass = "http://127.0.0.1:8008";
            };
          };
          "${domain}" = {
            root = "/storage/web/public";
            inherit forceSSL enableACME;
            locations =
              let
                extraConfig = ''
                  default_type application/json;
                  add_header Access-Control-Allow-Origin "*";
                '';
                inherit (pkgs.formats) json;
              in
              {
                "=/.well-known/matrix/server" = {
                  alias = (json { }).generate "well-known-matrix-server" { "m.server" = "matrix.${domain}:443"; };
                  inherit extraConfig;
                };
                "=/.well-known/matrix/client" = {
                  alias = (json { }).generate "well-known-matrix-client" {
                    "m.homeserver" = {
                      "base_url" = "https://matrix.${domain}";
                    };
                    "org.matrix.msc3575.proxy" = {
                      "url" = "https://matrix.${domain}";
                    };
                  };
                  inherit extraConfig;
                };
              };
          };
        };
      # some sane global defaults.
      recommendedBrotliSettings = true;
      recommendedProxySettings = true;
      recommendedZstdSettings = true;
      recommendedOptimisation = true;
      recommendedGzipSettings = true;
      recommendedTlsSettings = true;
      commonHttpConfig = ''
        real_ip_header CF-Connecting-IP;
        add_header 'Referrer-Policy' 'origin-when-cross-origin';
      '';
    };
    security.acme = {
      acceptTerms = true;
      defaults.email = "acme@${domain}";
    };
    networking.firewall.allowedTCPPorts = [
      80
      443
    ];
    users.users.nginx.extraGroups = [ "acme" ];
  };
}
