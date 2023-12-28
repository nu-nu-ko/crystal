{
  lib,
  pkgs,
  config,
  ...
}: {
  options.local.programs.firefox.enable = lib.mkEnableOption "";
  config = lib.mkIf config.local.programs.firefox.enable {
    home.file = {
      ".mozilla/firefox/profiles.ini".text = ''
        [Profile0]
        Name=${config.users.users.main.name}
        Path=${config.users.users.main.name}
        Default=1
        IsRelative=1

        [General]
        Version=2
      '';
      ".mozilla/firefox/${config.users.users.main.name}/chrome/userChrome.css".text = ''
      '';
      ".mozilla/firefox/${config.users.users.main.name}/chrome/userContent.css".text = ''
      '';
    };
    programs.firefox = {
      enable = true;
      # thankfully im not in need of such Support
      package = pkgs.firefox.override {cfg.speechSynthesisSupport = false;};
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
        ExtensionSettings = {
          "uBlock0@raymondhill.net" = {
            installation_mode = "force_installed";
            install_url = "https://addons.mozilla.org/firefox/downloads/file/4188488/ublock_origin-1.53.0.xpi";
          };
          "{446900e4-71c2-419f-a6a7-df9c091e268b}" = {
            installation_mode = "force_installed";
            install_url = "https://addons.mozilla.org/firefox/downloads/file/4180072/bitwarden_password_manager-2023.9.2.xpi";
          };
          "sponsorBlocker@ajay.app" = {
            installation_mode = "force_installed";
            install_url = "https://addons.mozilla.org/firefox/downloads/file/4178444/sponsorblock-5.4.23.xpi";
          };
          "Tab-Session-Manager@sienori" = {
            installation_mode = "force_installed";
            install_url = "https://addons.mozilla.org/firefox/downloads/file/4165190/tab_session_manager-6.12.2.xpi";
          };
        };
      };
    };
  };
}
