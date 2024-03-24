{
  lib,
  nuke,
  pkgs,
  config,
  colours,
  ...
}:
let
  inherit (nuke) mkEnable;
  inherit (lib) mkIf optionals;
in
{
  options.mods.desktop = {
    theme = {
      fonts = mkEnable;
      gtkqt = mkEnable;
      console = mkEnable;
    };
    setup = {
      audio = mkEnable;
      rgb = mkEnable;
      plymouth = mkEnable;
      greeter = mkEnable;
    };
    programs = {
      prism = mkEnable;
      steam = mkEnable;
      alacritty = mkEnable;
      fuzzel = mkEnable;
      firefox = mkEnable;
    };
  };
  config =
    let
      inherit (config.mods.desktop) setup theme programs;
      inherit (setup)
        audio
        greeter
        rgb
        plymouth
        ;
      inherit (theme) fonts gtkqt console;
      inherit (programs)
        prism
        steam
        alacritty
        firefox
        fuzzel
        ;
      inherit (colours) alpha accent primary;
    in
    {
      users.users.main.packages =
        optionals gtkqt [
          pkgs.capitaine-cursors-themed
          pkgs.gruvbox-dark-gtk
          pkgs.gruvbox-dark-icons-gtk
        ]
        ++ optionals steam [
          pkgs.protontricks
          pkgs.r2modman
        ]
        ++ optionals prism [ pkgs.prismlauncher-qt5 ]
        ++ optionals alacritty [ pkgs.alacritty ];

      ### steam
      programs = {
        firefox = mkIf firefox {
          enable = firefox;
          package = pkgs.firefox.override { cfg.speechSynthesisSupport = false; };
          policies = {
            Preferences = {
              "gfx.webrender.all" = true;
              "browser.aboutConfig.showWarning" = true;
              "browser.tabs.firefox-view" = true;
              "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
              "svg.context-properties.content.enabled" = true;
              "layout.css.has-selector.enabled" = true;
              "privacy.firstparty.isolate" = true;
              "browser.EULA.override" = true;
              "browser.tabs.inTitlebar" = 0;
            };
            CaptivePortal = false;
            DisableFirefoxStudies = true;
            DisablePocket = true;
            DisableTelemetry = true;
            DisableFirefoxAccounts = true;
            DisableProfileImport = true;
            DisableSetDesktopBackground = true;
            DisableFeedbackCommands = true;
            DisableFirefoxScreenshots = true;
            DontCheckDefaultBrowser = true;
            NoDefaultBookmarks = true;
            PasswordManagerEnabled = false;
            FirefoxHome = {
              Pocket = false;
              Snippets = false;
              TopSites = false;
              Highlights = false;
              Locked = true;
            };
            UserMessaging = {
              ExtensionRecommendations = false;
              SkipOnboarding = true;
            };
            Cookies = {
              Behavior = "accept";
              Locked = false;
            };
            ExtensionSettings =
              let
                addons = "https://addons.mozilla.org/firefox/downloads/file/";
                installation_mode = "force_installed";
              in
              {
                "uBlock0@raymondhill.net" = {
                  inherit installation_mode;
                  install_url = "${addons}4188488/ublock_origin-1.55.0.xpi";
                };
                "{446900e4-71c2-419f-a6a7-df9c091e268b}" = {
                  inherit installation_mode;
                  install_url = "${addons}4180072/bitwarden_password_manager-2024.2.0.xpi";
                };
                "sponsorBlocker@ajay.app" = {
                  inherit installation_mode;
                  install_url = "${addons}4178444/sponsorblock-5.5.4.xpi";
                };
                "Tab-Session-Manager@sienori" = {
                  inherit installation_mode;
                  install_url = "${addons}4165190/tab_session_manager-6.12.2.xpi";
                };
              };
          };
        };
        steam = mkIf steam {
          enable = steam;
          # required for source1 games.
          package = pkgs.steam.override {
            extraLibraries = pkgs: [
              pkgs.wqy_zenhei
              pkgs.pkgsi686Linux.gperftools
            ];
          };
        };
      };
      hardware = {
        xone.enable = steam;
        opengl.driSupport32Bit = steam;
      };

      environment.etc =
        {
          # gives a reliable path for the jdks
          "jdks/17".source = mkIf prism pkgs.openjdk17 + /bin;
          "jdks/8".source = mkIf prism pkgs.openjdk8 + /bin;
        }
        // mkIf gtkqt {
          "xdg/gtk-3.0/settings.ini".text = ''
            [Settings]
            gtk-cursor-theme-name=phinger-cursors
            gtk-font-name=SF Pro Text 12
            gtk-icon-theme-name=gruvbox-dark-icons
            gtk-theme-name=gruvbox-dark
          '';
        };
      home.file =
        let
          inherit (pkgs.formats) toml ini;
        in
        {
          ".config/alacritty/alacritty.toml".source = (toml { }).generate "alacritty.toml" {
            colors = {
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
          ".config/fuzzel/fuzzel.ini" = mkIf fuzzel {
            source = (ini { }).generate "fuzzel.ini" {
              colors = {
                background = primary.bg + "FF";
                text = primary.fg + "FF";
                match = primary.main + "FF";
                border = primary.main + "FF";
              };
            };
          };
          ".mozilla/firefox/profiles.ini".text = ''
            [Profile0]
            Name=${config.users.users.main.name}
            Path=${config.users.users.main.name}
            Default=1
            IsRelative=1
            [General]
            Version=2
          '';
        };
      services = {
        # greeter
        greetd = {
          enable = greeter;
          settings.default_session = mkIf greeter {
            command = "Hyprland";
            user = config.users.users.main.name;
          };
        };
        # rgb
        hardware.openrgb = {
          enable = rgb;
          motherboard = mkIf rgb "amd";
        };
        # audio
        pipewire = {
          enable = audio;
          alsa.enable = audio;
          pulse.enable = audio;
        };
      };
      # audio
      security.rtkit.enable = audio;
      # ply
      boot = {
        plymouth.enable = plymouth;
        initrd.verbose = !plymouth;
        kernelParams = mkIf plymouth [
          "quiet"
          "splash"
        ];
      };
      ### fonts
      fonts = mkIf fonts {
        packages = builtins.attrValues {
          sfFonts = pkgs.callPackage ../../pkgs/sfFonts.nix { };
          inherit (pkgs) noto-fonts-emoji noto-fonts-extra noto-fonts-cjk;
        };
        fontconfig = {
          defaultFonts = {
            sansSerif = [ "SF Pro Text" ];
            serif = [ "SF Pro Text" ];
            monospace = [ "Liga SFMono Nerd Font" ];
          };
          subpixel.rgba = "rgb";
        };
      };
      ### gtkqt
      programs.dconf = mkIf gtkqt {
        enable = gtkqt;
        profiles.user.databases = [
          {
            settings."org/gnome/desktop/interface" = {
              color-scheme = "prefer-dark";
              gtk-theme = "gruvbox-dark";
              icon-theme = "grubbox-dark-icons";
              cursor-theme = "phinger-cursors";
              font-name = "SF Pro Text 12";
              monospace-font-name = "Liga SFMono Nerd Font";
              document-font-name = "SF Pro Text 12";
            };
          }
        ];
      };
      qt = mkIf gtkqt {
        enable = gtkqt;
        style = "gtk2";
        platformTheme = "gtk2";
      };
      ### console
      console = mkIf console {
        font = "${pkgs.terminus_font}/share/consolefonts/ter-116n.psf.gz";
        colors = [
          "000000" # match boot.
          alpha.red
          alpha.green
          alpha.yellow
          alpha.blue
          alpha.magenta
          alpha.cyan
          alpha.white
          accent.red
          accent.green
          accent.yellow
          accent.blue
          accent.magenta
          accent.cyan
          accent.white
          primary.fg
        ];
      };
    };
}
