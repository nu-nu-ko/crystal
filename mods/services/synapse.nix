{
  config,
  _lib,
  lib,
  ...
}:
# needs nginx
{
  options._services.synapse = _lib.mkEnable;
  config = lib.mkIf config._services.synapse {
    age.secrets.synapse_shared = {
      file = ../../assets/age/synapse_shared.age;
      owner = "matrix-synapse";
    };
    services.matrix-synapse = {
      enable = true;
      settings = {
        server_name = config.networking.domain;
        max_upload_size = "10G";
        url_preview_enabled = true;
        presence.enabled = false;
        enable_metrics = true;
        withJemalloc = true;
        registration_shared_secret_path = config.age.secrets.synapse_shared.path;
        registration_requires_token = true;
        listeners =
          let
            tls = false;
            bind_addresses = [ "127.0.0.1" ];
          in
          [
            {
              inherit tls bind_addresses;
              port = 8008;
              resources = [
                {
                  compress = true;
                  names = [ "client" ];
                }
                {
                  compress = false;
                  names = [ "federation" ];
                }
              ];
              type = "http";
              x_forwarded = true;
            }
            {
              inherit tls bind_addresses;
              port = 9118;
              type = "metrics";
              resources = [ ];
            }
          ];
      };
    };
  };
}
