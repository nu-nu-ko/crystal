{lib, config, ...}: {
  # https://github.com/mountain-theme/Mountain
  options.local.mountain = lib.mkOption {};
  config.local.mountain = {
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
  };

  # base16 colours 
  options.local.colours = lib.mkOption {};
  config.local.colours = let
    c = config.local.mountain;
  in {
    primary = {
      bg = c.grayscale.yoru;
      fg = c.accent.yuki;
      main = c.accent.sakura;
    };
    alpha = {
      red = c.alpha.kaen;
      green = c.alpha.take;
      yellow = c.alpha.chikyu;
      blue = c.alpha.ume;
      magenta = c.alpha.kosumosu;
      cyan = c.alpha.shinkai;
      orange = c.alpha.aki;
      black = c.alpha.iwa;
      white = c.alpha.usagi;
    };
    accent = {
      red = c.accent.ichigo;
      green = c.accent.kusa;
      yellow = c.accent.suna;
      blue = c.accent.ajisai;
      magenta = c.accent.sakura;
      cyan = c.accent.kori;
      orange = c.accent.yuyake;
      black = c.accent.amagumo;
      white = c.accent.yuki;
    };
  };
}
