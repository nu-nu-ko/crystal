{
  config,
  pkgs,
  lib,
  inputs,
  modulesPath,
  ...
}: {
  #### awaiting PR
  disabledModules = ["${modulesPath}/services/misc/jellyfin.nix"];
  imports = ["${inputs.jelly}/nixos/modules/services/misc/jellyfin.nix"];
  ####
  options.service.web.jellyfin = lib.mkEnableOption "";
  config = let
    domain = "jelly.${config.service.web.domain}";
  in
    lib.mkIf config.service.web.jellyfin {
      services = {
        jellyfin = {
          enable = true;
          openFirewall = true;
          dataDir = "/storage/volumes/jellyfin";
        };
        nginx.virtualHosts."${domain}" = {
          forceSSL = true;
          enableACME = true;
          locations."/".proxyPass = "0.0.0.0:8096";
        };
      };
      users.users.jellyfin.extraGroups = ["media"];
      boot.kernelParams = ["i915.enable_guc=2"];
      hardware.opengl = {
        enable = true;
        extraPackages = [
          pkgs.intel-media-driver
          pkgs.intel-compute-runtime
        ];
      };
    };
}
