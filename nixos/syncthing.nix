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
    services.syncthing = {
      enable = true;
      systemService = true;
      user = "felix";
      group = "users";
      key = config.sops.secrets."${config.syncthing.keySecretName}".path;
      cert = config.sops.secrets."${config.syncthing.certSecretName}".path;
      overrideDevices = true;
      overrideFolders = true;
      settings = {
        devices = {
          "felix-phone" = {id = "NOGRX5K-UGF5USB-E6R54VA-4AIVMGQ-6GSNJMX-7G4ATT2-UZ23Z4D-2OWW3QG";};
          "felix-laptop" = {id = "LNJ37Z6-XJ5IZTK-OTM27G5-V5LJXUY-NXFUDIL-VZJQGOY-HPZCTZU-SSVSSQ3";};
          "fschwickerath" = {id = "JVQMQ4E-2EGCFM2-CTHAVBR-SK3E3I7-YY6Q5RW-3MQJNPM-Q5IFWWN-I6OIUQI";};
        };
        folders = let
          felix-devices = ["felix-phone" "felix-laptop" "fschwickerath"];
        in {
          "Bilder" = {
            path = "/home/felix/pictures/";
            id = "Bilder";
            devices = felix-devices;
          };
          "Dokumente" = {
            path = "/home/felix/documents/";
            id = "Dokumente";
            devices = felix-devices;
          };
          "General" = {
            path = "/home/felix/general/";
            id = "General";
            devices = felix-devices;
          };
          "Musik" = {
            path = "/home/felix/music/";
            id = "Musik";
            devices = felix-devices;
          };
        };
        gui = {
          user = "admin";
          password = "#g|dd);UZD'j2&;h>kiBTd@^z;zrLlN2";
          insecureSkipHostcheck = true;
        };
      };
    };
  };
}
