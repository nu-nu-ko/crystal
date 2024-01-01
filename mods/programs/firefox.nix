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
      ".mozilla/firefox/${config.users.users.main.name}/chrome/userChrome.css".text = let
        lc = config.local.colours;
      in ''
        :root {
          --sfwindow: #${lc.primary.bg};
          --sfsecondary: ${lc.normal.black};
        }
        .urlbarView {
          display: none !important;
        }
        /* Tabs colors  */
        #tabbrowser-tabs:not([movingtab])
          > #tabbrowser-arrowscrollbox
          > .tabbrowser-tab
          > .tab-stack
          > .tab-background[multiselected='true'],
        #tabbrowser-tabs:not([movingtab])
          > #tabbrowser-arrowscrollbox
          > .tabbrowser-tab
          > .tab-stack
          > .tab-background[selected='true'] {
          background-image: none !important;
          background-color: var(--toolbar-bgcolor) !important;
        }
        /* Inactive tabs color */
        #navigator-toolbox {
          background-color: var(--sfwindow) !important;
        }
        /* Window colors  */
        :root {
          --toolbar-bgcolor: var(--sfsecondary) !important;
          --tabs-border-color: var(--sfsecondary) !important;
          --lwt-sidebar-background-color: var(--sfwindow) !important;
          --lwt-toolbar-field-focus: var(--sfsecondary) !important;
        }
        /* Sidebar color  */
        #sidebar-box,
        .sidebar-placesTree {
          background-color: var(--sfwindow) !important;
        }
        /* Tabs elements  */
        .tab-close-button {
          display: none;
        }
        .tabbrowser-tab:not([pinned]) .tab-icon-image {
          display: none !important;
        }
        #nav-bar:not([tabs-hidden='true']) {
          box-shadow: none;
        }
        #tabbrowser-tabs[haspinnedtabs]:not([positionpinnedtabs])
          > #tabbrowser-arrowscrollbox
          > .tabbrowser-tab[first-visible-unpinned-tab] {
          margin-inline-start: 0 !important;
        }
        :root {
          --toolbarbutton-border-radius: 0 !important;
          --tab-border-radius: 0 !important;
          --tab-block-margin: 0 !important;
        }
        .tab-background {
          border-right: 0px solid rgba(0, 0, 0, 0) !important;
          margin-left: -4px !important;
        }
        .tabbrowser-tab:is([visuallyselected='true'], [multiselected])
          > .tab-stack
          > .tab-background {
          box-shadow: none !important;
        }
        .tabbrowser-tab[last-visible-tab='true'] {
          padding-inline-end: 0 !important;
        }
        #tabs-newtab-button {
          padding-left: 0 !important;
        }
        /* Url Bar  */
        #urlbar-input-container {
          background-color: var(--sfsecondary) !important;
          border: 1px solid rgba(0, 0, 0, 0) !important;
        }
        #urlbar-container {
          margin-left: 0 !important;
        }
        #urlbar[focused='true'] > #urlbar-background {
          box-shadow: none !important;
        }
        #navigator-toolbox {
          border: none !important;
        }
        /* Bookmarks bar  */
        .bookmark-item .toolbarbutton-icon {
          display: none;
        }
        toolbarbutton.bookmark-item:not(.subviewbutton) {
          min-width: 1.6em;
        }
        /* Toolbar  */
        #tracking-protection-icon-container,
        #urlbar-zoom-button,
        #star-button-box,
        #pageActionButton,
        #pageActionSeparator,
        #tabs-newtab-button,
        #back-button,
        #PanelUI-button,
        #forward-button,
        .tab-secondary-label {
          display: none !important;
        }
        .urlbarView-url {
          color: #dedede !important;
        }
        /* Disable elements  */
        #context-navigation,
        #context-savepage,
        #context-pocket,
        #context-sendpagetodevice,
        #context-selectall,
        #context-viewsource,
        #context-inspect-a11y,
        #context-sendlinktodevice,
        #context-openlinkinusercontext-menu,
        #context-bookmarklink,
        #context-savelink,
        #context-savelinktopocket,
        #context-sendlinktodevice,
        #context-searchselect,
        #context-sendimage,
        #context-print-selection {
          display: none !important;
        }
        #context_bookmarkTab,
        #context_moveTabOptions,
        #context_sendTabToDevice,
        #context_reopenInContainer,
        #context_selectAllTabs,
        #context_closeTabOptions {
          display: none !important;
        }
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
