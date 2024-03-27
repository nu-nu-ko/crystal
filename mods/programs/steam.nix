{
  config,
  _lib,
  lib,
  pkgs,
  ...
}:
{
  options._programs.steam = _lib.mkEnable;
  config = lib.mkIf config._programs.steam {
    users.users.main.packages = [
      # some game moding tools
      pkgs.protontricks
      pkgs.r2modman
    ];
    hardware = {
      xone.enable = true; # controller setup
      opengl.driSupport32Bit = true; # older games need these
    };
    programs.steam = {
      enable = true;
      package = pkgs.steam.override {
        # required for source1 titles
        extraLibraries = pkgs: [
          pkgs.wqy_zenhei
          pkgs.pkgsi686Linux.gperftools
        ];
      };
    };
  };
}
