{
  inputs,
  lib,
  ...
}: {
  flake.homeManagerModules.spotify = {
    pkgs,
    config,
    ...
  }: let
    spicetifyPkgs = inputs.spicetify-nix.legacyPackages.${pkgs.stdenv.hostPlatform.system};
  in {
    imports = [inputs.spicetify-nix.homeManagerModules.default];

    options = {
      spotify.enable = lib.mkEnableOption "Enables Spotify";
    };

    config = lib.mkIf config.spotify.enable {
      sops.secrets."spotify-client-id" = {};

      programs.spotify-player = {
        enable = true;
        settings = {
          client_id_command = {
            command = "${pkgs.coreutils}/bin/cat";
            args = ["${config.sops.secrets."spotify-client-id".path}"];
          };
          device = {
            name = "NixOS";
            device_type = "computer";
            bitrate = 320;
            autoplay = false;
          };
          cover_img_width = 14;
          cover_img_length = 32;
        };
      };

      programs.spicetify = {
        enable = true;
        theme = spicetifyPkgs.themes.catppuccin;
        colorScheme = "mocha";

        enabledExtensions = with spicetifyPkgs.extensions; [
          fullAppDisplay
          sectionMarker
          sessionStats
        ];

        enabledCustomApps = with spicetifyPkgs.apps; [
          lyricsPlus
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
    };
  };
}
