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
      themeFile = "tokyo_night_storm";
      extraConfig = ''
        cursor_blink_interval 0
        cursor_shape beam
        disable_ligatures never
      '';
    };
  };
}
