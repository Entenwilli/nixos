{
  inputs,
  lib,
  ...
}: {
  flake.homeManagerModules.helium-browser = {
    pkgs,
    config,
    ...
  }: {
    imports = [
      inputs.helium-browser.homeModules.default
    ];

    options = {
      helium-browser.enable = lib.mkEnableOption "Enable Helium Browser";
    };

    config = lib.mkIf config.helium-browser.enable {
      home.sessionVariables.BROWSER = "${config.programs.helium.package}/bin/helium";

      programs.helium = {
        enable = true;
        policies = {
          "BrowserSignin" = 0;
          "PasswordManagerEnabled" = false;
          "SyncDisabled" = true;
        };
      };

      xdg.mimeApps = let
        value = "helium.desktop";
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
        enable = true;
        associations.added = associations;
        defaultApplications = associations;
      };
    };
  };
}
