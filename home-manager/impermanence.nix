{
  config,
  lib,
  ...
}: {
  options = {
    impermanence.enable = lib.mkEnableOption "Enable impermanence";
  };

  config = lib.mkIf config.impermanence.enable {
    home.persistence."/persistent" = {
      hideMounts = true;
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
        ".thunderbird"
        ".config/syncthing"
        ".local/share/Anki2"
        ".local/share/zoxide"
        ".local/share/nvim"
        ".local/share/krita"
        ".local/state/wireplumber"
        ".config/fcitx5"
        ".config/obsidian"
        ".config/keepassxc"
        ".config/JetBrains"
        ".config/OpenTabletDriver"
        ".config/StardewValley"
        ".config/Vencord"
        ".config/discord"
        ".config/spotify"
        ".config/Element"
        ".cache/spotify"
        ".cache/spotify/Storage"
        ".local/share/PrismLauncher"
        ".var/app/com.core447.StreamController"
        ".zen"
        ".mozilla"
        ".local/share/bemoji"
        ".config/qt5ct"
        ".config/qt6ct"
        ".local/share/Steam"
        ".local/share/fish"
        ".local/share/shiori"
        ".local/share/qBittorrent"
        ".config/qBittorrent"
        ".config/unity3d/Ludeon Studios/RimWorld by Ludeon Studios/"
        ".config/unity3d/Vedal/Abandoned Archive/"
        ".zotero"
        ".local/share/JetBrains"
        ".local/share/Wonderdraft"
        ".config/session"
      ];
      files = [
        "start-webcam"
        ".config/user-dirs.dirs"
        {
          file = ".config/kritadisplayrc";
          method = "symlink";
        }
        {
          file = ".config/kritarc";
          method = "symlink";
        }
        {
          file = ".local/state/dolphinstaterc";
          method = "symlink";
        }
        ".config/filetypesrc"
        ".config/mimeapps.list"
        {
          file = ".config/kritashortcutsrc";
          method = "symlink";
        }
        ".config/sops/age/keys.txt"
        ".cache/keepassxc/keepassxc.ini"
        ".local/state/lazygit/state.yml"
        ".cache/rofi-entry-history.txt"
        ".cache/rofi3.druncache"
        {
          file = ".config/dolphinrc";
          method = "symlink";
        }
        {
          file = ".local/share/user-places.xbel";
          method = "symlink";
        }
        ".local/share/kxmlgui5/dolphin/dolphinui.rc"
      ];
    };
  };
}
