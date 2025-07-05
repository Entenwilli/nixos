{
  pkgs,
  lib,
  config,
  inputs,
  ...
}: let
  spicetifyPkgs = inputs.spicetify-nix.legacyPackages.${pkgs.system};
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
      theme = {
        name = "SleekHyDE";
        src = pkgs.fetchzip {
          url = "https://github.com/HyDE-Project/HyDE/raw/refs/heads/master/Source/arcs/Spotify_Sleek.tar.gz";
          hash = "sha256-kGdCHGht3ij3n118+x76SR3cAeIpjPHjq0Ow0YRW21I=";
        };
      };
      colorScheme = "custom";
      customColorScheme = with config.scheme; {
        text = "${base07}";
        subtext = "${base05}";
        nav-active-text = "${base0C}";
        main = "${base01}";
        main-secondary = "${base00}";
        main-elevated = "${base01}";
        main-transition = "${base01}";
        highlight = "${base03}";
        highlight-elevated = "${base03}";
        sidebar = "${base00}";
        player = "${base00}";
        card = "${base00}";
        window = "${base00}";
        shadow = "${base00}";
        button = "${base0C}";
        button-secondary = "${base07}";
        button-active = "${base0C}";
        button-disabled = "${base07}";
        nav-active = "${base02}";
        tab-active = "${base02}";
        notification = "${base03}";
        notification-error = "${base08}";
        playback-bar = "${base0C}";
        play-button = "${base0C}";
        play-button-active = "${base0C}";
        progress-fg = "${base0C}";
        progress-bg = "${base01}";
        pagelink-active = "${base03}";
        radio-btn-active = "${base03}";
        misc = "000000";
      };

      enabledExtensions = with spicetifyPkgs.extensions; [
        fullAppDisplay
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
}
