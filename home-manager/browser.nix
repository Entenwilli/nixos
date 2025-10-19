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
        NoDefaultBookmarks = true;
        OfferToSaveLogins = false;
        EnableTrackingProtection = {
          Value = true;
          Locked = true;
          Cryptomining = true;
          Fingerprinting = true;
        };
      };
      profiles."default" = {};
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
