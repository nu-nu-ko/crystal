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
      lcp = config.local.colours.primary;
      lca = config.local.colours.alpha;
      lcac = config.local.colours.accent;
    in ''
      colors:
        bright:
          black: '#${lcac.black}'
          red: '#${lcac.red}'
          green: '#${lcac.green}'
          yellow: '#${lcac.yellow}'
          blue: '#${lcac.blue}'
          magenta: '#${lcac.magenta}'
          cyan: '#${lcac.cyan}'
          white: '#${lcac.white}'
        normal:
          black: '#${lca.black}'
          red: '#${lca.red}'
          green: '#${lca.green}'
          yellow: '#${lca.yellow}'
          blue: '#${lca.blue}'
          magenta: '#${lca.magenta}'
          cyan: '#${lca.cyan}'
          white: '#${lca.white}'
        primary:
          background: '#${lcp.bg}'
          bright_foreground: '#${lcp.fg}'
          dim_foreground: '#${lcp.fg}'
          foreground: '#${lcp.fg}'
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
