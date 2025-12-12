{pkgs, ...}: {
  programs.mpv = {
    enable = true;
    package = pkgs.mpv-unwrapped.override {
      waylandSupport = true;
    };
    scripts = with pkgs.mpvScripts; [
      mpris
      uosc
    ];
    config = {
      profile = "high-quality";
      ytdl-format = "bestvideo+bestaudio";
      cache-default = 4000000;
    };
  };
}
