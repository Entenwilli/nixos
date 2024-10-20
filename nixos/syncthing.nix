{
  lib,
  config,
  ...
}: {
  options.syncthing = {
    enable = lib.mkEnableOption "Enable syncthing";
    keySecretName = lib.mkOption {
      type = lib.types.str;
      description = ''
        Syncthing key secret name that is used
      '';
    };
    certSecretName = lib.mkOption {
      type = lib.types.str;
      description = ''
        Syncthing cert secret name that is used
      '';
    };
  };

  config = lib.mkIf config.syncthing.enable {
    sops.secrets."${config.syncthing.keySecretName}" = {
      owner = "felix";
      group = "users";
    };
    sops.secrets."${config.syncthing.certSecretName}" = {
      owner = "felix";
      group = "users";
    };

    systemd.services.syncthing.environment.STNODEFAULTFOLDER = "true";
    services.syncthing = {
      enable = true;
      openDefaultPorts = true;
      user = "felix";
      group = "users";
      dataDir = "/home/felix";
      key = config.sops.secrets."${config.syncthing.keySecretName}".path;
      cert = config.sops.secrets."${config.syncthing.certSecretName}".path;
      settings = {
        devices = {
          "fschwickerath" = {
            name = "fschwickerath";
            id = "JVQMQ4E-2EGCFM2-CTHAVBR-SK3E3I7-YY6Q5RW-3MQJNPM-Q5IFWWN-I6OIUQI";
            autoAcceptFolders = true;
          };
        };
      };
    };
  };
}
