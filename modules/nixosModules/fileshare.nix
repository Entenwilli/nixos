{...}: {
  flake.nixosModules.fileshare = {
    config,
    lib,
    pkgs,
    utils,
    ...
  }: {
    options.fileshare.enable = lib.mkEnableOption "Enable fileshare";

    config = lib.mkIf config.fileshare.enable {
    systemd = {
      services.filebrowser = {
        after = ["network.target"];
        description = "FileBrowser";
        wantedBy = ["multi-user.target"];
        serviceConfig = {
          ExecStart = let
            settings = {
              address = "127.0.0.1";
              port = 27889;
              root = "/var/lib/filebrowser/data";
              database = "/var/lib/filebrowser/database.db";
              cache-dir = "/var/cache/filebrowser";
            };
            args = [
              (lib.getExe pkgs.filebrowser)
              "--config"
              ((pkgs.formats.json {}).generate "config.json" settings)
            ];
          in
            utils.escapeSystemdExecArgs args;

          StateDirectory = "filebrowser";
          CacheDirectory = "filebrowser";
          WorkingDirectory = "/var/lib/filebrowser/data";

          User = "filebrowser";
          Group = "filebrowser";
          UMask = "0077";

          NoNewPrivileges = true;
          PrivateDevices = true;
          ProtectKernelTunables = true;
          ProtectKernelModules = true;
          ProtectControlGroups = true;
          MemoryDenyWriteExecute = true;
          LockPersonality = true;
          RestrictAddressFamilies = [
            "AF_UNIX"
            "AF_INET"
            "AF_INET6"
          ];
          DevicePolicy = "closed";
          RestrictNamespaces = true;
          RestrictRealtime = true;
          RestrictSUIDSGID = true;
        };
      };

      tmpfiles.settings.filebrowser = {
        "/var/lib/filebrowser/data".d = {
          user = "filebrowser";
          group = "filebrowser";
          mode = "0700";
        };
        "/var/cache/filebrowser".d = {
          user = "filebrowser";
          group = "filebrowser";
          mode = "0700";
        };
        "/var/lib/filebrowser/database.db".d = {
          user = "filebrowser";
          group = "filebrowser";
          mode = "0700";
        };
      };
    };

    users.users.filebrowser = {
      group = "filebrowser";
      isSystemUser = true;
    };

    users.groups.filebrowser = {
    };

    services.traefik.dynamicConfigOptions = {
      http = {
        services.filebrowserService.loadBalancer.servers = [
          {
            url = "http://127.0.0.1:27889";
          }
        ];
        routers.filebrowserRouter = {
          entryPoints = ["websecure"];
          rule = "Host(`files.fschwickerath.de`)";
          service = "filebrowserService";
          tls.certResolver = "resolver";
          middlewares = ["chainNoAuth"];
        };
      };
    };

    services.borgbackup.jobs.backup.paths = ["/var/lib/filebrowser/"];
    };
  };
}
