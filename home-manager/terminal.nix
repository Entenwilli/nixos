{
  lib,
  pkgs,
  config,
  ...
}: {
  options = {
    terminal.enable = lib.mkEnableOption "Enable terminal";
  };

  config = lib.mkIf config.terminal.enable {
    programs.kitty = {
      enable = true;
      font = {
        name = "FiraCode Nerd Font";
        package = pkgs.nerdfonts.override {fonts = ["FiraCode"];};
        size = 14;
      };
      shellIntegration.enableFishIntegration = true;
      theme = "Tokyo Night";
    };
  };
}
