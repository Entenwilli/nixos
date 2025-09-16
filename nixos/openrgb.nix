{
  pkgs,
  lib,
  ...
}: {
  services.hardware.openrgb = {
    enable = true;
    motherboard = "amd";
  };

  systemd.services.openrgb = {
    description = "OpenRGB server daemon";
    after = ["network.target"];
    wants = ["dev-usb.device"];
    wantedBy = ["multi-user.target"];
    serviceConfig = {
      StateDirectory = "OpenRGB";
      WorkingDirectory = "/var/lib/OpenRGB";
      ExecStart = lib.mkForce "${pkgs.openrgb}/bin/openrgb --server --server-port 6742 --profile Default.orp";
      Restart = "always";
    };
  };
}
