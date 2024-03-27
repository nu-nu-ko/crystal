{
  config,
  _lib,
  lib,
  ...
}:
{
  options._system =
    let
      inherit (_lib) mkEnable;
      inherit (lib) mkOption types;
      inherit (types) str;
    in
    {
      timeZone.NZ = mkEnable;
      setHostKey = mkEnable;
      wired = {
        enable = mkEnable;
        ip = mkOption { type = str; };
        name = mkOption { type = str; };
      };
    };
  config =
    let
      inherit (lib) mkIf;
      inherit (config._system) timeZone setHostKey wired;
    in
    {
      networking = mkIf wired.enable {
        enableIPv6 = false;
        useDHCP = false;
      };
      systemd.network =
        let
          inherit (wired) enable name ip;
        in
        mkIf enable {
          inherit enable;
          networks.${name} = {
            inherit enable name;
            networkConfig = {
              DHCP = "no";
              DNSSEC = "yes";
              DNSOverTLS = "yes";
              DNS = [
                "1.1.1.1"
                "1.1.0.0"
              ];
            };
            address = [ "${ip}/24" ];
            routes = [ { routeConfig.Gateway = "192.168.0.1"; } ];
          };
        };
      services.openssh.hostKeys = mkIf setHostKey [
        {
          comment = "${config.networking.hostName} host";
          path = "/etc/ssh/${config.networking.hostName}_ed25519_key";
          type = "ed25519";
        }
      ];
      time.timeZone = mkIf timeZone.NZ "NZ";
      i18n.defaultLocale = mkIf timeZone.NZ "en_NZ.UTF-8";
    };
}
