{
  pkgs,
  config,
  lib,
  ...
}: {
  options.local.desktop.console = lib.mkEnableOption "";
  config = lib.mkIf config.local.desktop.console {
    console = {
      earlySetup = true;
      font = "${pkgs.terminus_font}/share/consolefonts/ter-116n.psf.gz";
      packages = with pkgs; [terminus_font];
      keyMap = "us";
      colors = let
        lc = config.local.colours;
      in [
        "000000" # prevent flicker
        lc.normal.red
        lc.normal.green
        lc.normal.yellow
        lc.normal.blue
        lc.normal.magenta
        lc.normal.cyan
        lc.normal.white
        lc.bright.red
        lc.bright.green
        lc.bright.yellow
        lc.bright.blue
        lc.bright.magenta
        lc.bright.cyan
        lc.bright.white
        lc.primary.fg
      ];
    };
    # auto specify username to tty logins
    services.getty = {
      extraArgs = ["--skip-login"];
      loginOptions = "-- ${config.users.users.main.name}";
    };
  };
}
