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
      fastfetch
      zoxide
      bat
    ];

    home.sessionVariables = {
      MANPAGER = "sh -c 'col -bx | bat -l man -p'";
    };

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
