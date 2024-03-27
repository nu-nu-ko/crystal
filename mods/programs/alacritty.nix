{
  _colours,
  config,
  pkgs,
  _lib,
  lib,
  ...
}:
{
  options._programs.alacritty = _lib.mkEnable;
  config = lib.mkIf config._programs.alacritty {
    users.users.main.packages = [ pkgs.alacritty ];
    _homeFile.".config/alacritty/alacritty.toml".source =
      (pkgs.formats.toml { }).generate "alacritty.toml"
        {
          colors =
            let
              inherit (_colours) accent alpha primary;
            in
            {
              bright = builtins.mapAttrs (_: prev: "#${prev}") accent;
              normal = builtins.mapAttrs (_: prev: "#${prev}") alpha;
              primary = {
                background = "#${primary.bg}";
                bright_foreground = "#${primary.fg}";
                dim_foreground = "#${primary.fg}";
              };
            };
          cursor = {
            style = "Underline";
            unfocused_hollow = false;
          };
          window = {
            dynamic_padding = false;
            dynamic_title = true;
            opacity = 1;
            padding = {
              x = 8;
              y = 8;
            };
          };
        };
  };
}
