{
  inputs,
  lib,
  ...
}: {
  flake.homeManagerModules.zen-browser = {
    pkgs,
    config,
    ...
  }: {
    imports = [
      inputs.zen-browser.homeModules.twilight
    ];

    options = {
      zen-browser.enable = lib.mkEnableOption "Enable Zen Browser";
    };

    config = lib.mkIf config.zen-browser.enable {
      programs.zen-browser.policies = {
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
    };
  };
}
