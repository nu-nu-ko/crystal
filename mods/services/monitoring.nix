{
  config,
  _lib,
  lib,
  ...
}:
# needs nginx
{
  options._services = {
    prometheus = _lib.mkEnable;
    web.grafana = _lib.mkWebOpt "ana" 8094;
  };
  config =
    let
      inherit (lib) mkIf;
      inherit (config._services) prometheus nginx web;
      inherit (web) grafana nextcloud;
    in
    {
      age.secrets.user_cloud_pom = mkIf web.nextcloud.enable {
        file = ../../assets/age/user_cloud_pom.age;
        owner = "nextcloud-exporter";
      };
      services = {
        grafana = mkIf grafana.enable {
          enable = true;
          settings.setver = {
            http_addr = "127.0.0.1";
            http_port = grafana.port;
            domain = "${grafana.dns}.${config.networking.domain}";
          };
        };
        prometheus = mkIf prometheus {
          enable = true;
          exporters = {
            zfs.enable = true;
            node = {
              enable = true;
              enabledCollectors = [ "systemd" ];
            };
            nginx.enable = nginx;
            nextcloud = mkIf nextcloud.enable {
              enable = true;
              username = "nuko";
              passwordFile = config.age.secrets.user_cloud_pom.path;
              url = "https://cloud.shimeji.cafe";
            };
          };
          scrapeConfigs = [
            {
              job_name = "library";
              static_configs = [ { targets = [ "127.0.0.1:9100" ]; } ];
            }
            {
              job_name = "zfs";
              static_configs = [ { targets = [ "127.0.0.1:9134" ]; } ];
            }
            {
              job_name = "nginx";
              static_configs = [ { targets = [ "127.0.0.1:9113" ]; } ];
            }
            {
              job_name = "synapse";
              metrics_path = "/_synapse/metrics";
              static_configs = [ { targets = [ "127.0.0.1:9118" ]; } ];
            }
            {
              job_name = "nextcloud";
              static_configs = [ { targets = [ "127.0.0.1:9205" ]; } ];
            }
          ];
        };
      };
    };
}
