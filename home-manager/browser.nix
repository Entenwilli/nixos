{
  config,
  lib,
  ...
}: {
  options = {
    browser.enable = lib.mkEnableOption "Enable Browser";
  };

  config = lib.mkIf config.browser.enable {
    programs.floorp = {
      enable = true;

      profiles = {
        default = {
          id = 0;
          isDefault = true;

          settings = {
            # Disable first time startup
            "browser.disableResetPrompt" = true;
            "browser.download.panel.shown" = true;
            "browser.feeds.showFirstRunUI" = false;
            "browser.messaging-system.whatsNewPanel.enabled" = false;
            "browser.rights.3.shown" = true;
            "browser.shell.checkDefaultBrowser" = false;
            "browser.shell.defaultBrowserCheckCount" = 1;
            "browser.startup.homepage_override.mstone" = "ignore";
            "browser.uitour.enabled" = false;
            "startup.homepage_override_url" = "";
            "trailhead.firstrun.didSeeAboutWelcome" = true;
            "browser.bookmarks.restore_default_bookmarks" = false;
            "browser.bookmarks.addedImportButton" = true;

            # Disable saving passwords
            "signon.rememberSignons" = false;

            # Other
            "floorp.browser.sidebar.enable" = false;
            "floorp.browser.sidebar.is.displayed" = false;
            "floorp.tabbar.style" = 2;
            "browser.formfill.enable" = false;
            "browser.contentblocking.category" = "strict";
            "browser.topsides.blockedSponsors" = ["cube-soft"];

            # Browser Toolbar UI
            "browser.ui.Customization.state" = builtins.toJSON {
              placements = {
                widget-overflow-fixed-list = [];
                unified-extensions-area = [
                  "dearrow_ajay_app-browser-action"
                  "ublock0_raymondhill_net-browser-action"
                  "sponsorblocker_ajay_app-browser-action"
                  "clipper_obsidian_md-browser-action"
                  "leechblockng_proginosko_com-browser-action"
                  "_4f391a9e-8717-4ba6-a5b1-488a34931fcb_-browser-action"
                  "firefoxcolor_mozilla_com-browser-action"
                  "_d04b0b40-3dab-4f0b-97a6-04ec3eddbfb0_-browser-action"
                  "keepassxc-browser_keepassxc_org-browser-action"
                  "languagetool-webextension_languagetool_org-browser-action"
                  "_cb31ec5d-c49a-4e5a-b240-16c767444f62_-browser-action"
                  "_76ef94a4-e3d0-4c6f-961a-d38a429a332b_-browser-action"
                  "myallychou_gmail_com-browser-action"
                ];
                nav-bar = [
                  "back-button"
                  "forward-button"
                  "customizableui-special-spring1"
                  "stop-reload-button"
                  "customizableui-special-spring4"
                  "urlbar-container"
                  "customizableui-special-spring2"
                  "customizableui-special-spring5"
                  "fxa-toolbar-menu-button"
                  "downloads-button"
                  "unified-extensions-button"
                ];
                toolbar-menubar = ["menubar-items"];
                TabsToolbar = [
                  "workspaces-toolbar-button"
                  "tabbrowser-tabs"
                  "new-tab-button"
                  "alltabs-button"
                  "firefox-view-button"
                ];
                PersonalToolbar = ["personal-bookmarks"];
              };
              seen = [
                "developer-button"
                "sidebar-reverse-position-toolbar"
                "undo-closed-tab"
                "profile-manager"
                "workspaces-toolbar-button"
                "clipper_obsidian_md-browser-action"
                "leechblockng_proginosko_com-browser-action"
                "_4f391a9e-8717-4ba6-a5b1-488a34931fcb_-browser-action"
                "firefoxcolor_mozilla_com-browser-action"
                "sponsorblocker_ajay_app-browser-action"
                "_d04b0b40-3dab-4f0b-97a6-04ec3eddbfb0_-browser-action"
                "keepassxc-browser_keepassxc_org-browser-action"
                "languagetool-webextension_languagetool_org-browser-action"
                "ublock0_raymondhill_net-browser-action"
                "dearrow_ajay_app-browser-action"
                "_cb31ec5d-c49a-4e5a-b240-16c767444f62_-browser-action"
                "_76ef94a4-e3d0-4c6f-961a-d38a429a332b_-browser-action"
                "myallychou_gmail_com-browser-action"
              ];
              dirtyAreaCache = ["nav-bar" "PersonalToolbar" "TabsToolbar" "toolbar-menubar" "unified-extensions-area"];
              currentVersion = 20;
              newElementCount = 5;
            };
          };
        };
      };
    };
  };
}
