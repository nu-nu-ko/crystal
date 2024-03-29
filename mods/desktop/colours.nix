{ ... }:
{
  _module.args.colours =
    let
      # https://github.com/mountain-theme/Mountain
      grayscale = {
        yoru = "0f0f0f";
        kesseki = "191919";
        iwa = "262626";
        tetsu = "393939";
        amagumo = "4c4c4c";
        gin = "767676";
        okami = "a0a0a0";
        tsuki = "bfbfbf";
        fuyu = "cacaca";
      };
      alpha = {
        ume = "8f8aac";
        kosumosu = "ac8aac";
        chikyu = "aca98a";
        kaen = "ac8a8c";
        aki = "c6a679";
        mizu = "8aacab";
        take = "8aac8b";
        shinkai = "8a98ac";
        iwa = "262626";
        usagi = "e7e7e7";
      };
      accent = {
        ajisai = "a39ec4";
        sakura = "c49ec4";
        suna = "c4c19e";
        ichigo = "c49ea0";
        yuyake = "ceb188";
        sora = "9ec3c4";
        kusa = "9ec49f";
        kori = "a5b4cb";
        amagumo = "4c4c4c";
        yuki = "f0f0f0";
      };
    in
    {
      primary = {
        bg = grayscale.yoru;
        fg = accent.yuki;
        main = accent.ichigo;
      };
      alpha = {
        red = alpha.kaen;
        green = alpha.take;
        yellow = alpha.chikyu;
        blue = alpha.ume;
        magenta = alpha.kosumosu;
        cyan = alpha.shinkai;
        black = alpha.iwa;
        white = alpha.usagi;
      };
      accent = {
        red = accent.ichigo;
        green = accent.kusa;
        yellow = accent.suna;
        blue = accent.ajisai;
        magenta = accent.sakura;
        cyan = accent.kori;
        black = accent.amagumo;
        white = accent.yuki;
      };
    };
}
