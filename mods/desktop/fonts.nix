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
        noto-fonts-emoji
        noto-fonts-extra
        # fallsbacks.
        noto-fonts
        noto-fonts-cjk
        dejavu_fonts
        # source1 games require this.
        wqy_zenhei
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
