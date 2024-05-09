{
  lib,
  pkgs,
  config,
  ...
}: {
  options = {
    fish.enable = lib.mkEnableOption "Enable fish";
  };

  config = lib.mkIf config.fish.enable {
    # Dependencies
    home.packages = with pkgs; [
      eza
      bat
      fastfetch
      zoxide
    ];

    programs.fish = {
      enable = true;
      package = pkgs.fish;
      shellAliases = {
        "ls" = "eza --icons";
        "ll" = "eza --icons -lah";
        "cat" = "bat";
        "dmenu" = "rofi -dmenu";
      };
      shellInit = ''
        set -g fish_greeting
        set -g theme_date_format "+%a %H:%M"
      '';
      interactiveShellInit = ''
        set -x GPG_TTP $(tty)
        set -x SSH_AUTH_SOCK $XDG_RUNTIME_DIR/ssh-agent
        ssh-add
        clear
        fastfetch
      '';
    };
  };
}
