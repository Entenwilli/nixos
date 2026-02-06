{pkgs, ...}: {
  home.packages = with pkgs; [
    yt-dlp
  ];
  programs.mpv = {
    enable = true;
    scripts = with pkgs.mpvScripts; [
      mpris
      uosc
      mpvacious
      autosubsync-mpv
    ];
    config = {
    };
  };

  xdg.configFile."mpv/mpv.conf".text = ''
    profile=gpu-hq
    gpu-context=wayland
    ytdl-format=bestvideo+bestaudio
    ytdl-raw-options-append="extractor-args=youtube:player-client=android_vr"
    hwdec=auto-safe
    vo=gpu

    alang=ja,jp,jpn,japanese,en,eng,english,English,enUS,en-US
    slang=ja,jp,jpn,japanese,en,eng,english,English,enUS,en-US
    save-position-on-quit=yes
    sub-auto=fuzzy
    subs-with-matching-audio=yes
    sub-ass-override=force
    sub-file-paths=ass:srt:sub:subs:subtitles
    af-add=scaletempo2
  '';

  xdg.configFile."mpv/script-opts/uosc.conf".text = ''
    default_directory=/media/videos/

    languages=jp,jpn,japanese
    subtitles_directory=/media/videos/anime/Subtitles/
  '';
}
