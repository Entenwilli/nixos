{...}: {
  flake.nixosModules.syncthing = {
    pkgs,
    config,
    options,
    lib,
    ...
  }: let
    cfg = config.syncthing;
  in {
    options.syncthing = {
      enable = lib.mkEnableOption "Enable syncthing";

      user = lib.mkOption {
        type = lib.types.str;
        default = "felix";
        description = "User syncthing runs as.";
      };
      group = lib.mkOption {
        type = lib.types.str;
        default = "users";
        description = "Group syncthing runs as.";
      };

      keySecretName = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "sops secret name holding key.pem, resolved via sops.secrets. Takes precedence over keyFile.";
      };
      certSecretName = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "sops secret name holding cert.pem, resolved via sops.secrets. Takes precedence over certFile.";
      };
      keyFile = lib.mkOption {
        type = lib.types.nullOr lib.types.path;
        default = null;
        description = "Path to key.pem, used when keySecretName is not set.";
      };
      certFile = lib.mkOption {
        type = lib.types.nullOr lib.types.path;
        default = null;
        description = "Path to cert.pem, used when certSecretName is not set.";
      };

      guiPassword = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Plaintext GUI password, embedded directly into settings.gui.password.";
      };
      guiPasswordFile = lib.mkOption {
        type = lib.types.nullOr lib.types.path;
        default = null;
        description = "Path to a file (e.g. a sops secret) containing the GUI password. Mutually exclusive with guiPassword.";
      };

      devices = lib.mkOption {
        type = lib.types.attrsOf lib.types.attrs;
        default = {
          "felix-phone" = {id = "NOGRX5K-UGF5USB-E6R54VA-4AIVMGQ-6GSNJMX-7G4ATT2-UZ23Z4D-2OWW3QG";};
          "felix-laptop" = {id = "LNJ37Z6-XJ5IZTK-OTM27G5-V5LJXUY-NXFUDIL-VZJQGOY-HPZCTZU-SSVSSQ3";};
          "fschwickerath" = {id = "JVQMQ4E-2EGCFM2-CTHAVBR-SK3E3I7-YY6Q5RW-3MQJNPM-Q5IFWWN-I6OIUQI";};
        };
        description = "Syncthing devices known to this host (services.syncthing.settings.devices).";
      };
      folders = lib.mkOption {
        type = lib.types.attrsOf lib.types.attrs;
        default = let
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
        description = "Syncthing folders for this host (services.syncthing.settings.folders).";
      };

      runsInGraphicalSession = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = ''
          Whether syncthing-init should wait for a graphical session (desktop/laptop)
          rather than starting at multi-user boot (servers).
        '';
      };

      exposeViaTraefik = lib.mkEnableOption "Expose the syncthing GUI via traefik";
      enableBorgBackup = lib.mkEnableOption "Back up the syncthing data directory via borgbackup";
    };

    config = lib.mkIf cfg.enable (lib.mkMerge [
      {
        systemd.services."syncthing-init" = lib.mkIf cfg.runsInGraphicalSession {
          wantedBy = lib.mkForce ["graphical.target"];
          after = lib.mkForce ["syncthing.service" "graphical.target"];
        };

        services.syncthing = {
          enable = true;
          package = pkgs.syncthing;
          systemService = true;
          user = cfg.user;
          group = cfg.group;
          key =
            if cfg.keySecretName != null
            then config.sops.secrets."${cfg.keySecretName}".path
            else cfg.keyFile;
          cert =
            if cfg.certSecretName != null
            then config.sops.secrets."${cfg.certSecretName}".path
            else cfg.certFile;
          guiPasswordFile = cfg.guiPasswordFile;
          overrideDevices = true;
          overrideFolders = true;
          settings = {
            inherit (cfg) devices folders;
            gui =
              {
                user = "admin";
                insecureSkipHostcheck = true;
              }
              // lib.optionalAttrs (cfg.guiPasswordFile == null && cfg.guiPassword != null) {
                password = cfg.guiPassword;
              };
          };
        };

        services.traefik.dynamicConfigOptions = lib.mkIf cfg.exposeViaTraefik {
          http = {
            services.syncthingService.loadBalancer.servers = [
              {
                url = "http://127.0.0.1:8384";
              }
            ];
            routers.syncthingRouter = {
              entryPoints = ["websecure"];
              rule = "Host(`sync.fschwickerath.de`)";
              service = "syncthingService";
              tls.certResolver = "resolver";
              middlewares = ["chainNoAuth"];
            };
          };
        };

        services.borgbackup.jobs = lib.mkIf cfg.enableBorgBackup {
          backup.paths = ["/var/lib/syncthing/"];
        };
      }
      (lib.optionalAttrs (options ? impermanence) {
        environment.persistence."/persistent".directories = lib.mkIf config.impermanence.enable [
          "/var/lib/syncthing/"
        ];
      })
    ]);
  };
}
