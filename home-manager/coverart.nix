{
  pkgs,
  config,
  lib,
  ...
}: let
  cover_bin = pkgs.writeScriptBin "cover" ''
    #!/usr/bin/env fish
    while true
      kitty +kitten icat "$(playerctl metadata mpris:artUrl)"
      sleep 1
    end
  '';
  cover = pkgs.symlinkJoin {
    name = "cover";
    paths = [cover_bin];
    buildInputs = [pkgs.makeWrapper];
    postBuild = "wrapProgram $out/bin/cover --prefix PATH : $out/bin";
  };
in {
  options = {
    coverart.enable = lib.mkEnableOption "Enable cover art script";
  };

  config = lib.mkIf config.coverart.enable {
    home.packages = [
      cover
    ];

    xdg.desktopEntries.cover = {
      name = "Cover";
      exec = "${pkgs.kitty}/bin/kitty --app-id cover --name cover ${cover}/bin/cover";
    };
  };
}
