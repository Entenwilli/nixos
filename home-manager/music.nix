{...}: {
  programs.spotify-player = {
    enable = true;
    settings = {
      theme = "tokyonight";
      playback_window_position = "Bottom";
      cover_img_length = 10;
      cover_img_height = 10;
      cover_img_scale = 1.0;
      name = "nixos-laptop";
    };
    themes = [
      {
        name = "tokyonight";
        palette = {
          background = "#1f2335";
          foreground = "#c0caf5";
          black = "#414868";
          red = "#f7768e";
          green = "#9ece6a";
          yellow = "#e0af68";
          blue = "#2ac3de";
          magenta = "#bb9af7";
          cyan = "#7dcfff";
          white = "#eee8d5";
          bright_black = "#24283b";
          bright_red = "#ff4499";
          bright_green = "#73daca";
          bright_yellow = "#657b83";
          bright_blue = "#839496";
          bright_magenta = "#ff007c";
          bright_cyan = "#93a1a1";
          bright_white = "#fdf6e3";
        };
        component_style = {
          playback_metadata = {
            fg = "White";
            modifiers = ["Dim"];
          };
        };
      }
    ];
  };

  xdg.desktopEntries.spotify = {
    type = "Application";
    name = "Spotify";
    genericName = "Music Player";
    exec = "spotify_player";
    terminal = true;
    mimeType = ["x-scheme-handler/spotify"];
    categories = ["Audio" "Music" "Player" "AudioVideo"];
  };
}
