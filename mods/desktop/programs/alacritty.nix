{
  config,
  lib,
  nuke,
  pkgs,
  colours,
  ...
}:
{
  options.program.alacritty = nuke.mkEnable;
  config = lib.mkIf config.program.alacritty {
    users.users.main.packages = [ pkgs.alacritty ];
    home.file.".config/alacritty/alacritty.toml".source =
      (pkgs.formats.toml { }).generate "alacritty.toml"
        {
          colors = {
            bright = builtins.mapAttrs (_: prev: "#${prev}") (colours.accent);
            normal = builtins.mapAttrs (_: prev: "#${prev}") (colours.alpha);
            primary =
              let
                inherit (colours.primary) bg fg;
              in
              {
                background = "#${bg}";
                bright_foreground = "#${fg}";
                dim_foreground = "#${fg}";
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
          font = {
            normal = {
              family = "Liga SFMono Nerd Font";
              style = "Regular";
            };
          };
        };
  };
}