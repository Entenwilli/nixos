{
  self,
  inputs,
  lib,
  ...
}: {
  flake.nixosModules.i18n = {
    pkgs,
    config,
    ...
  }: {
    imports = [
    ];

    options = {
      i18n.enable = lib.mkEnableOption "Enable internationalization";
    };

    config = lib.mkIf config.i18n.enable {
      i18n = {
        defaultLocale = "en_US.UTF-8";
        extraLocales = ["ja_JP.UTF-8/UTF-8"];
        extraLocaleSettings = {LC_TIME = "de_DE.UTF-8";};
      };
    };
  };
}
