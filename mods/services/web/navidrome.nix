{
  modulesPath,
  inputs,
  config,
  pkgs,
  _lib,
  lib,
  ...
}:
{
  # awaiting 288687
  disabledModules = [ "${modulesPath}/services/audio/navidrome.nix" ];
  imports = [ "${inputs.navi}/nixos/modules/services/audio/navidrome.nix" ];

  options._services.web.navidrome = _lib.mkWebOpt "navi" 8093;
  config =
    let
      inherit (config._services.web.navidrome) enable port;
    in
    lib.mkIf enable {
      assertions = _lib.mkAssert config._services.nginx;
      services.navidrome = {
        inherit enable;
        group = "media";
        package = inputs.navi.legacyPackages.${pkgs.system}.navidrome;
        settings = {
          MusicFolder = "/storage/media/Music";
          CacheFolder = "/var/cache/navidrome";
          EnableDownloads = true;
          EnableSharing = true;
          Port = port;
        };
      };
    };
}
