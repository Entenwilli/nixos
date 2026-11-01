{...}: {
  flake.nixosModules.paperless = {
    config,
    lib,
    ...
  }: {
    options.paperless.enable = lib.mkEnableOption "Enable paperless";

    config = lib.mkIf config.paperless.enable {
      sops.secrets."paperless-env" = {
        restartUnits = [
          "paperless-web.service"
          "paperless-scheduler.service"
          "paperless-task-queue.service"
          "paperless-consumer.service"
        ];
      };

      services.paperless = {
        enable = true;
        environmentFile = config.sops.secrets."paperless-env".path;
        settings = {
          PAPERLESS_OCR_LANGUAGES = "deu eng";
          PAPERLESS_OCR_LANGUAGE = "deu";
        };
        domain = "paperless.fschwickerath.de";
        database.createLocally = true;
      };

      services.traefik.dynamicConfigOptions = {
        http = {
          services.paperlessService.loadBalancer.servers = [
            {
              url = "http://127.0.0.1:28981";
            }
          ];
          routers.paperlessRouter = {
            entryPoints = ["websecure"];
            rule = "Host(`paperless.fschwickerath.de`)";
            service = "paperlessService";
            tls.certResolver = "resolver";
            middlewares = ["chainNoAuth"];
          };
        };
      };

      services.borgbackup.jobs.backup.paths = ["/var/lib/paperless/" "/var/lib/redis-paperless/"];
    };
  };
}
