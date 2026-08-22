{
  self,
  lib,
  ...
}: {
  flake.homeManagerModules.browser = {
    pkgs,
    config,
    ...
  }: {
    imports = [
      self.homeManagerModules.zen-browser
      self.homeManagerModules.helium-browser
    ];

    options = {
      browser.enable = lib.mkEnableOption "Enable Browser";
    };

    config = lib.mkIf config.browser.enable {
      zen-browser.enable = true;
      helium-browser.enable = true;
    };
  };
}
