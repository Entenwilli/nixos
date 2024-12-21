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
    programs.bat.enable = true;

    # Enable process monitor
    programs.btop.enable = true;
  };
}
