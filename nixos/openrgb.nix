{
  lib,
  config,
  ...
}: {
  services.hardware.openrgb = {
    enable = true;
    motherboard = "amd";
    startupProfile = "Default.orp";
  };

  systemd.services.openrgb.serviceConfig.ExecStart = lib.mkForce "${lib.getExe config.services.hardware.openrgb.package} --server --server-port 6742 --config /var/lib/OpenRGB/ --noautoconnect";
}
