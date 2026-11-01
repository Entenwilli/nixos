{...}: {
  flake.nixosModules.shiori = {
    config,
    lib,
    ...
  }: {
    options.shiori.enable = lib.mkEnableOption "Enable shiori";

    config = lib.mkIf config.shiori.enable {
      services.shiori = {
      enable = true;
      address = "127.0.0.1";
      port = 27556;
    };

    services.traefik.dynamicConfigOptions = {
      http = {
        services.bookmarksService.loadBalancer.servers = [
          {
            url = "http://127.0.0.1:27556";
          }
        ];
        routers.bookmarksRouter = {
          entryPoints = ["websecure"];
          rule = "Host(`bookmarks.fschwickerath.de`)";
          service = "bookmarksService";
          tls.certResolver = "resolver";
          middlewares = ["chainNoAuth"];
        };
      };
    };

    services.borgbackup.jobs.backup.paths = [
      "/var/lib/shiori/"
    ];
    };
  };
}
