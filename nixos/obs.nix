{
  pkgs,
  config,
  ...
}: {
  boot.extraModulePackages = with config.boot.kernelPackages; [
    v4l2loopback
  ];
  boot.extraModprobeConfig = ''
    options v4l2loopback devices=2 video_nr=0,1 card_label="Webcam,OBS Virtual Cam" exclusive_caps=1,1
  '';
  security.polkit.enable = true;

  programs.obs-studio.enable = true;
  programs.obs-studio.plugins = with pkgs.obs-studio-plugins; [
    obs-ndi
    wlrobs
    obs-backgroundremoval
    obs-pipewire-audio-capture
    obs-composite-blur
    obs-shaderfilter
    obs-scale-to-sound
    obs-move-transition
    obs-gradient-source
    obs-replay-source
    obs-source-clone
    obs-3d-effect
    obs-livesplit-one
    waveform
    obs-gstreamer
    obs-vaapi
    obs-vkcapture
  ];
}
