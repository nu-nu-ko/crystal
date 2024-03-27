{
  config,
  pkgs,
  _lib,
  lib,
  ...
}:
{
  options._services.web.jellyfin = _lib.mkWebOpt "jelly" 8096;
  config =
    let
      inherit (config._services.web.jellyfin) enable;
    in
    lib.mkIf enable {
      assertions = _lib.mkAssert config._services.nginx;
      services.jellyfin = {
        inherit enable;
        group = "media";
      };
      systemd.services = {
        jellyfin.serviceConfig = {
          # hardening which isnt appropriate for upstream.
          DeviceAllow = [ "/dev/dri/renderD128" ];
          ProtectSystem = "strict";
          ProtectHome = "yes";
          ReadWritePaths = [
            "/var/lib/jellyfin"
            "/var/cache/jellyfin"
            "/storage/media"
          ];
          # these options seem reasonable for upstream but likely not worth a PR
          ProtectClock = true;
          ProtectProc = "invisible";
          ProcSubset = "pid";
          CapabilityBoundingSet = "";
        };
      };
      # video hardware accel setup
      boot.kernelParams = [ "i915.enable_guc=2" ];
      hardware.opengl = {
        inherit enable;
        extraPackages = [
          pkgs.intel-media-driver
          pkgs.intel-compute-runtime
        ];
      };
    };
}
