{lib, ...}: {
  flake.homeManagerModules.zellij = {
    pkgs,
    config,
    ...
  }: {
    options = {
      zellij.enable = lib.mkEnableOption "Enable zellij";
    };

    config = lib.mkIf config.zellij.enable {
      home.persistence."/persistent".directories = lib.mkIf config.impermanence.enable [
        ".cache/zellij"
      ];

      programs.zellij = {
        enable = true;
        enableFishIntegration = true;
        exitShellOnExit = true;
        settings = {
          theme = "catppuccin-macchiato";
          show_startup_tips = false;
        };
      };
    };
  };
}
