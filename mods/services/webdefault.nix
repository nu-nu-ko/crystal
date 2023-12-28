{
  config,
  lib,
  ...
}: {
  options.local.services.web = {
    enable = lib.mkEnableOption "";
    domain = lib.mkOption {type = lib.types.str;};
  };
  config = let
    base = "nuko.city";
  in
    lib.mkIf config.local.services.web.enable {
      networking.firewall.allowedTCPPorts = [80 443 8080];
      security.acme = {
        acceptTerms = true;
        defaults.email = "acme@${base}";
      };
      services.nginx = {
        enable = true;
        commonHttpConfig = ''
          real_ip_header CF-Connecting-IP;
          add_header 'Referrer-Policy' 'origin-when-cross-origin';
          add_header X-Frame-Options DENY;
          add_header X-Content-Type-Options nosniff;
        '';
        recommendedProxySettings = true;
        recommendedTlsSettings = true;
        recommendedOptimisation = true;
        recommendedGzipSettings = true;
        /*virtualHosts."${base}" = {
          forceSSL = true;
          enableACME = true;
          serverAliases = [base];
          root = "/storage/volumes/website/public";
        };*/
      };
    };
}
