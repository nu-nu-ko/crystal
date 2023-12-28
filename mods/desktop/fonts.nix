{
  pkgs,
  config,
  lib,
  ...
}: {
  options.local.desktop.fonts = lib.mkEnableOption "";
  config = lib.mkIf config.local.desktop.fonts {
    fonts = {
      packages = with pkgs; [
        (pkgs.callPackage ../../pkgs/sfFonts.nix {})
        # mostly as fallsbacks.
        noto-fonts
        noto-fonts-cjk
        noto-fonts-emoji
        noto-fonts-extra
        dejavu_fonts
      ];
      fontconfig = {
        defaultFonts = {
          sansSerif = ["SF Pro Text"];
          serif = ["SF Pro Text"];
          monospace = ["Liga SFMono Nerd Font"];
        };
        enable = true;
        antialias = true;
        hinting.enable = true;
        hinting.autohint = true;
        subpixel.rgba = "rgb";
      };
    };
  };
}
