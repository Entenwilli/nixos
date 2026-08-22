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
          asbplayer
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
