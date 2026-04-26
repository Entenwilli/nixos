{
  lib,
  config,
  pkgs,
  ...
}: {
  options = {
    zellij.enable = lib.mkEnableOption "Enable zellij";
  };

  config = lib.mkIf config.zellij.enable {
    home.persistence."/persistent".directories = [
      ".cache/zellij"
    ];

    programs.zellij = {
      enable = true;
      # HACK: Unstable until fixed in stable
      package = pkgs.unstable.zellij;
      enableFishIntegration = true;
      exitShellOnExit = true;
      settings = {
        theme = "catppuccin-macchiato";
        show_startup_tips = false;
      };
    };
  };
}
