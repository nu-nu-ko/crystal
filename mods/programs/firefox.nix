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
      #https://github.com/crambaud/waterfall
      ".mozilla/firefox/${config.users.users.main.name}/chrome/userChrome.css".text = let
        lc = config.local.colours;
      in ''
        :root {
           --window-colour:               #${lc.primary.bg};
           --secondary-colour:            #${lc.normal.black};
           --inverted-colour:             #${lc.primary.fg};
           --uc-identity-color-blue:      #${lc.normal.blue};
           --uc-identity-color-turquoise: #${lc.normal.cyan};
           --uc-identity-color-green:     #${lc.normal.green};
           --uc-identity-color-yellow:    #${lc.normal.yellow};
           --uc-identity-color-orange:    #${lc.normal.orange};
           --uc-identity-color-red:       #${lc.normal.red};
           --uc-identity-color-pink:      #${lc.bright.red};
           --uc-identity-color-purple:    #${lc.normal.magenta};
           --urlbar-popup-url-color: var(--uc-identity-color-purple) !important;
           --uc-border-radius: 0;
           --uc-urlbar-width: clamp(200px, 50vw, 600px);
           --uc-active-tab-width:   clamp( 100px, 20vw, 200px);
           --uc-inactive-tab-width: clamp( 100px, 20vw, 200px);
           --show-tab-close-button: none;
           --show-tab-close-button-hover: -moz-inline-box;
           --container-tabs-indicator-margin: 0px;
        }
        /* showing only the back button */
        #back-button{ display: -moz-inline-box !important; }
        #forward-button{ display: none !important; }
        #stop-button{ display: none !important; }
        #reload-button{ display: none !important; }
        #star-button{ display: none !important; }
        #urlbar-zoom-button { display: none !important; }
        #PanelUI-button { display: -moz-inline-box !important;}
        #reader-mode-button{ display: none !important; }
        #tracking-protection-icon-container { display: none !important; }
        #identity-box { display: none !important } /* hides encryption AND permission items */
        /* #identity-permission-box { display: none !important; }*/ /* only hides permission items */
        .tab-secondary-label { display: none !important; }
        #pageActionButton { display: none !important; }
        #page-action-buttons { display: none !important; }
        :root {
           --uc-theme-colour:                          var(--window-colour);
           --uc-hover-colour:                          var(--secondary-colour);
           --uc-inverted-colour:                       var(--inverted-colour);
           --button-bgcolor:                           var(--uc-theme-colour)    !important;
           --button-hover-bgcolor:                     var(--uc-hover-colour)    !important;
           --button-active-bgcolor:                    var(--uc-hover-colour)    !important;
           --toolbar-bgcolor:                          var(--uc-theme-colour)    !important;
           --toolbarbutton-hover-background:           var(--uc-hover-colour)    !important;
           --toolbarbutton-active-background:          var(--uc-hover-colour)    !important;
           --toolbarbutton-border-radius:              var(--uc-border-radius)   !important;
           --lwt-toolbar-field-focus:                  var(--uc-theme-colour)    !important;
           --toolbarbutton-icon-fill:                  var(--uc-inverted-colour) !important;
           --toolbar-field-focus-background-color:     var(--secondary-colour)   !important;
           --toolbar-field-color:                      var(--uc-inverted-colour) !important;
           --toolbar-field-focus-color:                var(--uc-inverted-colour) !important;
           --tabs-border-color:                        var(--uc-theme-colour)    !important;
           --tab-border-radius:                        var(--uc-border-radius)   !important;
           --lwt-text-color:                           var(--uc-inverted-colour) !important;
           --lwt-tab-text:                             var(--uc-inverted-colour) !important;
           --lwt-sidebar-background-color:             var(--uc-hover-colour)    !important;
           --lwt-sidebar-text-color:                   var(--uc-inverted-colour) !important;
           --arrowpanel-border-color:                  var(--uc-theme-colour)    !important;
           --arrowpanel-border-radius:                 var(--uc-border-radius)   !important;
           --arrowpanel-background:                    var(--uc-theme-colour)    !important;
           --arrowpanel-color:                         var(--inverted-colour)    !important;
           --autocomplete-popup-highlight-background:  var(--uc-inverted-colour) !important;
           --autocomplete-popup-highlight-color:       var(--uc-inverted-colour) !important;
           --autocomplete-popup-hover-background:      var(--uc-inverted-colour) !important;
           --tab-block-margin: 2px !important;
        }
        window,
        #main-window,
        #toolbar-menubar,
        #TabsToolbar,
        #PersonalToolbar,
        #navigator-toolbox,
        #sidebar-box,
        #nav-bar {
           -moz-appearance: none !important;
           border: none !important;
           box-shadow: none !important;
           background: var(--uc-theme-colour) !important;
        }
        #PersonalToolbar toolbarbutton:not(:hover),
        #bookmarks-toolbar-button:not(:hover) { filter: grayscale(1) !important; }
        .titlebar-buttonbox-container { display: -moz-inline-box !important; }
        .titlebar-spacer { display: none !important; }
        #tabbrowser-tabs[haspinnedtabs]:not([positionpinnedtabs])
           > #tabbrowser-arrowscrollbox
           > .tabbrowser-tab[first-visible-unpinned-tab] { margin-inline-start: 0 !important; }
        .tabbrowser-tab
           >.tab-stack
           > .tab-background { box-shadow: none !important;  }
        .tabbrowser-tab
           > .tab-stack
           > .tab-background { background: var(--uc-theme-colour) !important; }
        .tabbrowser-tab[selected]
           > .tab-stack
           > .tab-background { background: var(--uc-hover-colour) !important; }
        .tabbrowser-tab:not([pinned]) .tab-close-button { display: var(--show-tab-close-button) !important; }
        .tabbrowser-tab:not([pinned]):hover .tab-close-button { display: var(--show-tab-close-button-hover) !important }
        .tabbrowser-tab[selected][fadein]:not([pinned]) { max-width: var(--uc-active-tab-width) !important; }
        .tabbrowser-tab[fadein]:not([selected]):not([pinned]) { max-width: var(--uc-inactive-tab-width) !important; }
        .tabbrowser-tab[usercontextid]
           > .tab-stack
           > .tab-background
           > .tab-context-line {
              margin: -1px var(--container-tabs-indicator-margin) 0 var(--container-tabs-indicator-margin) !important;
              border-radius: var(--tab-border-radius) !important;
        }
        .tab-icon-image:not([pinned]) { opacity: 1 !important; }
        .tab-icon-overlay:not([crashed]),
        .tab-icon-overlay[pinned][crashed][selected] {
          top: 5px !important;
          z-index: 1 !important;
          padding: 1.5px !important;
          inset-inline-end: -8px !important;
          width: 16px !important; height: 16px !important;
          border-radius: 10px !important;
        }
        .tab-icon-overlay:not([sharing], [crashed]):is([soundplaying], [muted], [activemedia-blocked]) {
          stroke: transparent !important;
          background: transparent !important;
          opacity: 1 !important; fill-opacity: 0.8 !important;
          color: currentColor !important;
          stroke: var(--uc-theme-colour) !important;
          background-color: var(--uc-theme-colour) !important;
        }
        .tabbrowser-tab[selected] .tab-icon-overlay:not([sharing], [crashed]):is([soundplaying], [muted], [activemedia-blocked]) {
          stroke: var(--uc-hover-colour) !important;
          background-color: var(--uc-hover-colour) !important;
        }
        .tab-icon-overlay:not([pinned], [sharing], [crashed]):is([soundplaying], [muted], [activemedia-blocked]) { margin-inline-end: 9.5px !important; }
        .tabbrowser-tab:not([image]) .tab-icon-overlay:not([pinned], [sharing], [crashed]) {
          top: 0 !important;
          padding: 0 !important;
          margin-inline-end: 5.5px !important;
          inset-inline-end: 0 !important;
        }
        .tab-icon-overlay:not([crashed])[soundplaying]:hover,
        .tab-icon-overlay:not([crashed])[muted]:hover,
        .tab-icon-overlay:not([crashed])[activemedia-blocked]:hover {
           color: currentColor !important;
           stroke: var(--uc-inverted-colour) !important;
           background-color: var(--uc-inverted-colour) !important;
           fill-opacity: 0.95 !important;
        }
        .tabbrowser-tab[selected] .tab-icon-overlay:not([crashed])[soundplaying]:hover,
        .tabbrowser-tab[selected] .tab-icon-overlay:not([crashed])[muted]:hover,
        .tabbrowser-tab[selected] .tab-icon-overlay:not([crashed])[activemedia-blocked]:hover {
           color: currentColor !important;
           stroke: var(--uc-inverted-colour) !important;
           background-color: var(--uc-inverted-colour) !important;
           fill-opacity: 0.95 !important;
        }
        #TabsToolbar .tab-icon-overlay:not([crashed])[soundplaying],
        #TabsToolbar .tab-icon-overlay:not([crashed])[muted],
        #TabsToolbar .tab-icon-overlay:not([crashed])[activemedia-blocked] { color: var(--uc-inverted-colour) !important; }
        #TabsToolbar .tab-icon-overlay:not([crashed])[soundplaying]:hover,
        #TabsToolbar .tab-icon-overlay:not([crashed])[muted]:hover,
        #TabsToolbar .tab-icon-overlay:not([crashed])[activemedia-blocked]:hover { color: var(--uc-theme-colour) !important; }
        #nav-bar {
           border:     none !important;
           box-shadow: none !important;
           background: transparent !important;
        }
        #navigator-toolbox { border-bottom: none !important; }
        #urlbar,
        #urlbar * { box-shadow: none !important; }
        #urlbar-background { border: var(--uc-hover-colour) !important; }
        #urlbar[focused="true"]
           > #urlbar-background,
        #urlbar:not([open])
           > #urlbar-background { background: transparent !important; }
        #urlbar[open]
           > #urlbar-background { background: var(--uc-theme-colour) !important; }
        .urlbarView-row:hover
           > .urlbarView-row-inner,
        .urlbarView-row[selected]
           > .urlbarView-row-inner { background: var(--uc-hover-colour) !important; }
        @media (min-width: 1000px) {
           #TabsToolbar { margin-left: var(--uc-urlbar-width) !important; }
           #nav-bar { margin: calc((var(--urlbar-min-height) * -1) - 8px) calc(100vw - var(--uc-urlbar-width)) 0 0 !important; }
        }
        .identity-color-blue      { --identity-tab-color: var(--uc-identity-color-blue)      !important; --identity-icon-color: var(--uc-identity-color-blue)      !important; }
        .identity-color-turquoise { --identity-tab-color: var(--uc-identity-color-turquoise) !important; --identity-icon-color: var(--uc-identity-color-turquoise) !important; }
        .identity-color-green     { --identity-tab-color: var(--uc-identity-color-green)     !important; --identity-icon-color: var(--uc-identity-color-green)     !important; }
        .identity-color-yellow    { --identity-tab-color: var(--uc-identity-color-yellow)    !important; --identity-icon-color: var(--uc-identity-color-yellow)    !important; }
        .identity-color-orange    { --identity-tab-color: var(--uc-identity-color-orange)    !important; --identity-icon-color: var(--uc-identity-color-orange)    !important; }
        .identity-color-red       { --identity-tab-color: var(--uc-identity-color-red)       !important; --identity-icon-color: var(--uc-identity-color-red)       !important; }
        .identity-color-pink      { --identity-tab-color: var(--uc-identity-color-pink)      !important; --identity-icon-color: var(--uc-identity-color-pink)      !important; }
        .identity-color-purple    { --identity-tab-color: var(--uc-identity-color-purple)    !important; --identity-icon-color: var(--uc-identity-color-purple)    !important; }
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
