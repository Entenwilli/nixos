{
  config,
  lib,
  ...
}: {
  options = {
    impermanence.enable = lib.mkEnableOption "Enable impermanence";
  };

  config = lib.mkIf config.impermanence.enable {
    home.persistence."/persistent/home/felix" = {
      directories = [
        ".factorio"
        ".ssh"
        ".xlcore"
        ".gnupg"
        "development"
        "documents"
        "downloads"
        "general"
        "music"
        "nixos"
        "pictures"
        ".config/syncthing"
        ".local/share/Anki2"
        ".local/share/zoxide"
        ".local/share/nvim"
        ".local/share/krita"
        ".config/fcitx5"
        ".config/obsidian"
        ".config/keepassxc"
        ".config/JetBrains"
        ".config/OpenTabletDriver"
        ".config/StardewValley"
        ".config/Vencord"
        ".config/discord"
        ".config/spotify"
        ".cache/spotify/Storage"
        ".local/share/PrismLauncher"
        ".var/app/com.core447.StreamController"
        ".zen"
        ".mozilla"
        ".local/share/bemoji"
        {
          directory = ".local/share/Steam";
          method = "symlink";
        }
        ".local/share/fish"
        ".local/share/shiori"
      ];
      files = [
        "start-webcam"
        ".config/user-dirs.dirs"
        ".config/kritadisplayrc"
        ".config/kritarc"
        ".config/kritashortcutsrc"
        ".config/sops/age/keys.txt"
        ".cache/keepassxc/keepassxc.ini"
        ".local/state/lazygit/state.yml"
        ".cache/rofi-entry-history.txt"
        ".cache/rofi3.druncache"
        ".local/share/zoxide/db.zo"
      ];
      allowOther = true;
    };
  };
}
