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
        lc.alpha.red
        lc.alpha.green
        lc.alpha.yellow
        lc.alpha.blue
        lc.alpha.magenta
        lc.alpha.cyan
        lc.alpha.white
        lc.accent.red
        lc.accent.green
        lc.accent.yellow
        lc.accent.blue
        lc.accent.magenta
        lc.accent.cyan
        lc.accent.white
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
