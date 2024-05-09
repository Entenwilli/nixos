{
  pkgs,
  inputs,
  ...
}: let
  spicetifyPkgs = inputs.spicetify-nix.packages.${pkgs.system}.default;
in {
  imports = [inputs.spicetify-nix.homeManagerModule];

  programs.spicetify = {
    enable = true;
    theme = spicetifyPkgs.themes.Sleek;
    colorScheme = "Deep";
    enabledExtensions = with spicetifyPkgs.extensions; [
      fullAppDisplay
      shuffle
      hidePodcasts
    ];
  };

  xdg.desktopEntries.spotify = {
    type = "Application";
    name = "Spotify";
    genericName = "Music Player";
    icon = "spotify-client";
    exec = "spotify --enable-features=UseOzonePlatform --ozone-platform=wayland %U";
    terminal = false;
    mimeType = ["x-scheme-handler/spotify"];
    categories = ["Audio" "Music" "Player" "AudioVideo"];
  };
}
