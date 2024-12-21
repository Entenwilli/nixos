{
  lib,
  pkgs,
  config,
  ...
}: {
  options = {
    discord = {
      enable = lib.mkEnableOption "Enable discord";
    };
  };

  config = lib.mkIf config.discord.enable {
    home.packages = with pkgs; [webcord];
    xdg.desktopEntries.webcord = {
      name = "Discord";
      genericName = "Discord";
      exec = "webcord --enable-features=UseOzonePlatform --ozone-platform=wayland";
      icon = "webcord";
      terminal = false;
      type = "Application";
      categories = ["Network"];
    };
  };
}
