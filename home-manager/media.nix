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
}
