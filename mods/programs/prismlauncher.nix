{
  config,
  _lib,
  lib,
  pkgs,
  ...
}:
{
  options._programs.prismlauncher = _lib.mkEnable;
  config = lib.mkIf config._programs.prismlauncher {
    users.users.main.packages = [ pkgs.prismlauncher ];
    environment.etc = {
      # gives a reliable path for the jdks
      "jdks/17".source = pkgs.openjdk17 + /bin;
      "jdks/8".source = pkgs.openjdk8 + /bin;
    };
  };
}
