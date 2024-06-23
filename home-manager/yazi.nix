{
  lib,
  config,
  pkgs,
  ...
}: {
  options = {
    yazi.enable = lib.mkEnableOption "Enable yazi";
  };

  config = lib.mkIf config.yazi.enable {
    home.packages = with pkgs; [ueberzugpp];

    programs.yazi = {
      enable = true;
      enableFishIntegration = true;
    };
  };
}
