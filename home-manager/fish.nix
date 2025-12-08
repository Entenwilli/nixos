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
      MANPAGER = "sh -c 'awk '\''{ gsub(/\x1B\[[0-9;]*m/, \"\", \$0); gsub(/.\x08/, \"\", \$0); print }'\'' | bat -p -lman'";
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
      interactiveShellInit = lib.strings.concatStrings [
        (
          if config.impermanence.enable
          then ''
            set -x _ZO_DATA_DIR "/persistent/home/felix/.local/share"
          ''
          else ""
        )
        ''
          set -x _ZO_RESOLVE_SYMLINKS "1"
          set -x GPG_TTP $(tty)
          set -x SSH_AUTH_SOCK $XDG_RUNTIME_DIR/ssh-agent
          ssh-add
          clear
          fastfetch
        ''
      ];
    };
  };
}
