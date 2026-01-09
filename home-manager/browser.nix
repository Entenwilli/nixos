{
  inputs,
  config,
  lib,
  system,
  pkgs,
  ...
}: {
  imports = [
    inputs.zen-browser.homeModules.twilight
  ];

  options = {
    browser.enable = lib.mkEnableOption "Enable Browser";
  };

  config = lib.mkIf config.browser.enable {
    programs.zen-browser = {
      enable = true;
      policies = {
        AutofillAddressEnabled = false;
        AutofillCreditCardEnabled = false;
        DisableAppUpdate = true;
        DisableFeedbackCommands = true;
        DisableFirefoxStudies = true;
        DisablePocket = true;
        DisableTelemetry = true;
        DontCheckDefaultBrowser = true;
        OfferToSaveLogins = false;
        EnableTrackingProtection = {
          Value = true;
          Locked = true;
          Cryptomining = true;
          Fingerprinting = true;
        };
        Preferences = let
          mkLockedAttrs = builtins.mapAttrs (_: value: {
            Value = value;
            Status = "locked";
          });
        in
          mkLockedAttrs {
            "browser.aboutConfig.showWarning" = false;
            "browser.tabs.warnOnClose" = false;
            "media.videocontrols.picture-in-picture.video-toggle.enabled" = true;
            # Disable swipe gestures (Browser:BackOrBackDuplicate, Browser:ForwardOrForwardDuplicate)
            "browser.gesture.swipe.left" = "";
            "browser.gesture.swipe.right" = "";
            "browser.tabs.hoverPreview.enabled" = true;
            "browser.newtabpage.activity-stream.feeds.topsites" = false;
            "browser.topsites.contile.enabled" = false;

            "privacy.resistFingerprinting" = true;
            "privacy.resistFingerprinting.randomization.canvas.use_siphash" = true;
            "privacy.resistFingerprinting.randomization.daily_reset.enabled" = true;
            "privacy.resistFingerprinting.randomization.daily_reset.private.enabled" = true;
            "privacy.resistFingerprinting.block_mozAddonManager" = true;
            "privacy.spoof_english" = 1;

            "privacy.firstparty.isolate" = true;
            "network.cookie.cookieBehavior" = 5;
            "dom.battery.enabled" = false;

            "gfx.webrender.all" = true;
            "extensions.autoDisableScopes" = 0;
          };
      };
      profiles."default" = {
        isDefault = true;
        settings = {
          "zen.welcome-screen.seen" = true;
          "zen.workspaces.continue-where-left-off" = true;
        };
        containersForce = true;
        containers = {
          Default = {
            color = "blue";
            icon = "briefcase";
            id = 1;
          };
        };
        spacesForce = true;
        spaces = {
          "Default" = {
            id = "79106985-252e-431b-8b2f-d080c4ddc8d3";
            position = 1001;
            icon = "📂";
          };
          "Study" = {
            id = "32cf9052-c37c-4e61-bcb1-757b7e116213";
            position = 1002;
            icon = "📚";
          };
          "D&D" = {
            id = "418596af-98cd-4f8e-a205-c338b2b6428d";
            position = 1003;
            icon = "🐉";
          };
        };
        pinsForce = true;
        pins = let
          workspaces = config.programs.zen-browser.profiles."default".spaces;
          containers = config.programs.zen-browser.profiles."default".containers;
        in {
          "Timetracking" = {
            id = "ad28fe9d-de70-412a-bb80-484ff2f72feb";
            container = containers.Default.id;
            url = "https://time.fschwickerath.de";
            isEssential = true;
            position = 101;
          };
          "Dashboard" = {
            id = "c8de7133-2962-4e73-959e-e6e42c1f9d6a";
            container = containers.Default.id;
            url = "https://dashboard.fschwickerath.de";
            isEssential = true;
            position = 102;
          };
          "Wanikani" = {
            id = "4797778b-04a1-4308-bdc1-97a124494346";
            container = containers.Default.id;
            url = "https://wanikani.com";
            isEssential = true;
            position = 103;
          };
          "Illias" = {
            id = "017c7063-718e-4ad5-a992-48c6000aba2c";
            workspace = workspaces."Study".id;
            url = "https://illias.studium.kit.edu";
            position = 200;
          };
        };
        search = {
          force = true;
          default = "ecosia";
        };
        extensions.packages = with pkgs.nur.repos.rycee.firefox-addons; [
          ublock-origin
          dearrow
          web-clipper-obsidian
          keepassxc-browser
          languagetool
          leechblock-ng
          seventv
          sponsorblock
          tampermonkey
          youtube-recommended-videos # Unhook
          yomitan
          refined-github
          indie-wiki-buddy
        ];
        bookmarks = {
          force = true;
          settings = [
            {
              name = "Google Calendar";
              url = "https://calendar.google.com";
            }
            {
              name = "Mail";
              url = "https://box.fschwickerath.de/mail/";
            }
            {
              name = "YouTube";
              url = "https://youtube.com";
            }
            {
              name = "Twitch";
              url = "twitch.tv";
            }
            {
              name = "NixOS Search";
              url = "https://search.nixos.org/packages";
            }
            {
              name = "Home Manager Option Search";
              url = "https://home-manager-options.extranix.com";
            }
            {
              name = "Wanikani";
              url = "https://wanikani.com";
            }
            {
              name = "KIT Illias";
              url = "https://illias.studium.kit.edu";
            }
            {
              name = "KIT Campus Management";
              url = "https://campus.studium.kit.edu";
            }
          ];
        };
        userChrome = pkgs.fetchurl {
          url = "https://raw.githubusercontent.com/catppuccin/zen-browser/refs/heads/main/themes/Mocha/Blue/userChrome.css";
          hash = "sha256-/BULRbmPtuQUcAgROylMP+YUdhRiQKWKjKhfWYCxpuQ=";
        };
        userContent = pkgs.fetchurl {
          url = "https://raw.githubusercontent.com/catppuccin/zen-browser/refs/heads/main/themes/Mocha/Blue/userContent.css";
          hash = "sha256-X+1EODQpILtAbIZOpI8gx6YqxohFc/wLff8A8Cu+OZs=";
        };
      };
    };

    xdg.mimeApps = let
      value = let
        zen-browser = inputs.zen-browser.packages.${system}.twilight;
      in
        zen-browser.meta.desktopFileName;

      associations = builtins.listToAttrs (map (name: {
          inherit name value;
        }) [
          "application/x-extension-shtml"
          "application/x-extension-xhtml"
          "application/x-extension-html"
          "application/x-extension-xht"
          "application/x-extension-htm"
          "x-scheme-handler/unknown"
          "x-scheme-handler/mailto"
          "x-scheme-handler/chrome"
          "x-scheme-handler/about"
          "x-scheme-handler/https"
          "x-scheme-handler/http"
          "application/xhtml+xml"
          "application/json"
          "text/plain"
          "text/html"
        ]);
    in {
      associations.added = associations;
      defaultApplications = associations;
    };
  };
}
