{
  lib,
  config,
  ...
}: {
  options = {
    impermanence.enable = lib.mkEnableOption "Enable impermanence";
  };

  config = lib.mkIf config.impermanence.enable {
    programs.fuse.userAllowOther = true;
    environment.persistence."/persistent" = {
      enable = true;
      hideMounts = true;
      directories = [
        "/var/log"
        "/var/lib/bluetooth"
        "/var/lib/nixos"
        "/var/lib/OpenRGB"
        "/var/lib/systemd/coredump"
        "/etc/NetworkManager/system-connections"
      ];
      files = [
        "/etc/machine-id"
        "/var/db/sudo/lectured/1000"
      ];
    };
  };
}
