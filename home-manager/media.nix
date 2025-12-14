{pkgs, ...}: {
  home.packages = with pkgs; [
    yt-dlp
  ];
  programs.mpv = {
    enable = true;
    scripts = with pkgs.mpvScripts; [
      mpris
      uosc
    ];
    config = {
      profile = "gpu-hq";
      gpu-context = "wayland";
      ytdl-format = "bestvideo+bestaudio";
      cache-default = 4000000;
      hwdec = "auto-safe";
      vo = "gpu";
    };
  };

  xdg.configFile."mpv/script-opts/uosc.conf".text = ''
    default_directory=/media/videos/

    languages=jp,jpn,japanese
    subtitles_directory=/media/videos/anime/Subtitles/
  '';
}
