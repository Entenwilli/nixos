{
  lib,
  config,
  pkgs,
  ...
}: {
  options.gaming = {
    enable = lib.mkEnableOption "Enable gaming environment";
  };

  config = lib.mkIf config.gaming.enable {
    environment.systemPackages = with pkgs; [
      xivlauncher
      gamemode
      mangohud
      prismlauncher
    ];

    programs.steam = {
      enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
      localNetworkGameTransfers.openFirewall = true;
      gamescopeSession = {
        enable = true;
      };
      package = pkgs.steam.override {
        extraProfile = ''
          unset TZ
        '';
      };
      extraCompatPackages = with pkgs; [proton-ge-bin];
    };

    programs.gamemode.enable = true;
    programs.gamescope.enable = true;
  };
}
