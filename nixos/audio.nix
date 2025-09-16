{pkgs, ...}: {
  programs.noisetorch.enable = true;
  systemd.user.services.noisetorch = {
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.noisetorch}/bin/noisetorch -i 'alsa_input.usb-M-Audio_M-Track_2X2-00.analog-stereo'";
    };
    wantedBy = ["graphical-session.target"];
  };
}
