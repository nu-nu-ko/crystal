{
  config,
  pkgs,
  lib,
  ...
}: {
  options.local.services.web.conduit.enable = lib.mkEnableOption "";
  config = let
    base = "${config.local.services.web.domain}";
    domain = "matrix.${base}";
    well_known_server = pkgs.writeText "well-known-matrix-server" ''
      {
        "m.server": "${domain}"
      }
    '';
    well_known_client = pkgs.writeText "well-known-matrix-client" ''
      {
        "m.homeserver": {
          "base_url": "https://${domain}"
        }
      }
    '';
  in
    lib.mkIf config.local.services.web.conduit.enable {
      services = {
        matrix-conduit = {
          enable = true;
          settings.global = {
            server_name = "${base}";
          };
        };
        nginx = {
          virtualHosts = {
            "${domain}" = {
              forceSSL = true;
              enableACME = true;
              listen = [
                {
                  addr = "0.0.0.0";
                  port = 443;
                  ssl = true;
                }
                {
                  addr = "[::]";
                  port = 443;
                  ssl = true;
                }
                {
                  addr = "0.0.0.0";
                  port = 8448;
                  ssl = true;
                }
                {
                  addr = "[::]";
                  port = 8448;
                  ssl = true;
                }
              ];
              locations."/_matrix/" = {
                proxyPass = "http://backend_conduit$request_uri";
                proxyWebsockets = true;
                extraConfig = ''
                  proxy_set_header Host $host;
                  proxy_buffering off;
                '';
              };
              extraConfig = ''
                merge_slashes off;
              '';
            };

            "${base}" = {
              locations."=/.well-known/matrix/server" = {
                alias = "${well_known_server}";
                extraConfig = ''
                  # Set the header since by default NGINX thinks it's just bytes
                  default_type application/json;
                '';
              };
              locations."=/.well-known/matrix/client" = {
                alias = "${well_known_client}";
                extraConfig = ''
                  # Set the header since by default NGINX thinks it's just bytes
                  default_type application/json;

                  # https://matrix.org/docs/spec/client_server/r0.4.0#web-browser-clients
                  #add_header Access-Control-Allow-Origin "*";
                '';
              };
            };
          };
          upstreams = {
            "backend_conduit" = {
              servers = {
                "[::1]:${toString config.services.matrix-conduit.settings.global.port}" = {};
              };
            };
          };
        };
      };
      networking.firewall.allowedTCPPorts = [80 443 8448];
      networking.firewall.allowedUDPPorts = [80 443 8448];
    };
}
