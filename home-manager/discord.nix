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
    home.packages = with pkgs; [
      vesktop
      teamspeak6-client
    ];
  };
}
