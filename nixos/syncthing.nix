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
    systemd.services.syncthing.environment.STNODEFAULTFOLDER = "true";
    systemd.services.syncthing.after = ["sops-nix.service"];
    services.syncthing = {
      enable = true;
      user = "felix";
      configDir = "/home/felix/.config/syncthing";
      key = config.sops.secrets."${config.syncthing.keySecretName}".path;
      cert = config.sops.secrets."${config.syncthing.certSecretName}".path;
      systemService = true;
      settings = {
        devices = {
          "fschwickerath" = {
            name = "fschwickerath";
            id = "JVQMQ4E-2EGCFM2-CTHAVBR-SK3E3I7-YY6Q5RW-3MQJNPM-Q5IFWWN-I6OIUQI";
            autoAcceptFolders = true;
          };
          "smartphone" = {
            name = "smartphone";
            id = "NOGRX5K-UGF5USB-E6R54VA-4AIVMGQ-6GSNJMX-7G4ATT2-UZ23Z4D-2OWW3QG";
          };
        };
        folders = {
          "pictures" = {
            id = "Bilder";
            path = "~/pictures";
            devices = ["fschwickerath"];
          };
          "documents" = {
            id = "Dokumente";
            path = "~/documents";
            devices = ["fschwickerath"];
          };
          "general" = {
            id = "General";
            path = "~/general";
            devices = ["fschwickerath"];
          };
          "music" = {
            id = "Musik";
            path = "~/music";
            devices = ["fschwickerath"];
          };
        };
      };
    };
  };
}
