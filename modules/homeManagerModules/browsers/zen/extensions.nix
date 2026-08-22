{
  inputs,
  lib,
  ...
}: {
  flake.homeManagerModules.zen-browser-extensions = {
    pkgs,
    config,
    ...
  }: {
    config = lib.mkIf config.zen-browser.enable {
      programs.zen-browser.profiles.default = {
        extensions.packages = with pkgs.nur.repos.rycee.firefox-addons; [
          ublock-origin
          dearrow
          web-clipper-obsidian
          keepassxc-browser
          languagetool
          leechblock-ng
          sponsorblock
          tampermonkey
          youtube-recommended-videos # Unhook
          yomitan
          (asbplayer.override rec {
            version = "1.20.1";
            url = "https://github.com/asbplayer/asbplayer/releases/download/v${version}/asbplayer-extension-firefox-${version}.xpi";
            sha256 = "sha256-CYKguAT4tiq292jQte5BX9ESpqbDzkI2Q9vKoTl3Cq8=";
          })
          refined-github
          indie-wiki-buddy
        ];

        settings = {
          "uBlock0@raymondhill.net" = {
            force = true;
            settings.selectedFilterLists = [
              "user-filters"
              "ublock-filters"
              "ublock-badware"
              "ublock-privacy"
              "ublock-unbreak"
            ];
          };
        };
      };
    };
  };
}
