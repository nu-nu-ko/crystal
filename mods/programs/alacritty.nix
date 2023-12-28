{
  config,
  lib,
  pkgs,
  ...
}: {
  options.local.programs.alacritty.enable = lib.mkEnableOption "";
  config = lib.mkIf config.local.programs.alacritty.enable {
    users.users.main.packages = [pkgs.alacritty];
    home.file.".config/alacritty/alacritty.yml".text = let
      lc = config.local.colours;
    in ''
      colors:
        bright:
          black: '#${lc.bright.black}'
          red: '#${lc.bright.red}'
          green: '#${lc.bright.green}'
          yellow: '#${lc.bright.yellow}'
          blue: '#${lc.bright.blue}'
          magenta: '#${lc.bright.magenta}'
          cyan: '#${lc.bright.cyan}'
          white: '#${lc.bright.white}'
        normal:
          black: '#${lc.normal.black}'
          red: '#${lc.normal.red}'
          green: '#${lc.normal.green}'
          yellow: '#${lc.normal.yellow}'
          blue: '#${lc.normal.blue}'
          magenta: '#${lc.normal.magenta}'
          cyan: '#${lc.normal.cyan}'
          white: '#${lc.normal.white}'
        primary:
          background: '#${lc.primary.bg}'
          bright_foreground: '#${lc.primary.fg}'
          dim_foreground: '#${lc.primary.fg}'
          foreground: '#${lc.primary.fg}'
      cursor:
        style: Underline
        unfocused_hollow: false
      window:
        dynamic_padding: false
        dynamic_title: true
        opacity: 1
        padding:
          x: 8
          y: 8
    '';
  };
}
