{...}: {
  flake.homeManagerModules.discord = {
    pkgs,
    config,
    lib,
    ...
  }: {
    options = {
      discord = {
        enable = lib.mkEnableOption "Enable discord";
      };
    };

    config = lib.mkIf config.discord.enable {
      home.packages = [
        pkgs.unstable.vesktop
      ];
    };
  };
}
