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
    home.packages = with pkgs; [ueberzugpp kdePackages.dolphin kdePackages.qtimageformats qview];

    programs.yazi = {
      enable = true;
      enableFishIntegration = true;
    };
  };
}
