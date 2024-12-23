{
  pkgs,
  config,
  lib,
  ...
}: {
  options = {
    cli-tools.enable = lib.mkEnableOption "Enable CLI tools";
  };

  config = lib.mkIf config.cli-tools.enable {
    # Install cli packages
    home.packages = with pkgs; [
      fzf
      ripgrep
      jq
      socat
      fd
    ];

    # Enable cat alternative
    programs.bat = {
      enable = true;
      config = {
        theme = "catppuccin";
      };
      themes = {
        catppuccin = {
          src = pkgs.fetchFromGitHub {
            owner = "catppuccin";
            repo = "bat";
            rev = "d2bbee4f7e7d5bac63c054e4d8eca57954b31471";
            sha256 = "sha256-x1yqPCWuoBSx/cI94eA+AWwhiSA42cLNUOFJl7qjhmw=";
          };
          file = "themes/Catppuccin Mocha.tmTheme";
        };
      };
    };

    # Enable process monitor
    programs.btop.enable = true;
  };
}
