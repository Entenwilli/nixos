{
  lib, pkgs, config, ...
}: {
  options = {
    rofi.enable = lib.mkEnableOption "Enable rofi";
  };

  config = lib.mkIf config.wofi.enable {
    programs.rofi = {
        enable = true;
        package = pkgs.rofi-wayland;
      };
  };
}
