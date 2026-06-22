{lib, ...}: {
  flake.homeManagerModules.zoxide = {
    pkgs,
    config,
    ...
  }: {
    options = {
      zoxide.enable = lib.mkEnableOption "Enable zoxide";
    };

    config = lib.mkIf config.zoxide.enable {
      programs.zoxide = {
        enable = true;
        enableFishIntegration = true;
        options = ["--cmd" "cd"];
      };
    };
  };
}
