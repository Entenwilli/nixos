{
  inputs,
  config,
  lib,
  pkgs,
  ...
}: {
  options = {
    browser.enable = lib.mkEnableOption "Enable Browser";
  };

  config = lib.mkIf config.browser.enable {
    home.packages = [inputs.zen-browser.packages.${pkgs.system}.default];
  };
}
