{lib, ...}: {
  flake.homeManagerModules.university = {
    pkgs,
    config,
    ...
  }: {
    options = {
      university.enable = lib.mkEnableOption "Enable university tools";
    };

    config = lib.mkIf config.university.enable {
      home.sessionVariables = {
        ANKI_WAYLAND = 1;
      };
      home.packages = with pkgs; [
        zotero
        anki
        glib
      ];
    };
  };
}
