{
  config,
  pkgs,
  _lib,
  lib,
  ...
}:
{
  options._programs.firefox = _lib.mkEnable;
  config = lib.mkIf config._programs.firefox {
    programs.firefox = {
      enable = true;
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
    _homeFile.".mozilla/firefox/profiles.ini".text = ''
      [Profile0]
      Name=${config.users.users.main.name}
      Path=${config.users.users.main.name}
      Default=1
      IsRelative=1
      [General]
      Version=2
    '';
  };
}
