{...}: {
  flake.nixosModules.uptime = {
    config,
    lib,
    ...
  }: {
    options.uptime.enable = lib.mkEnableOption "Enable uptime";

    config = lib.mkIf config.uptime.enable {
    services.uptime-kuma = {
      enable = true;
      settings = {
        PORT = "27080";
      };
    };

    services.traefik.dynamicConfigOptions = {
      http = {
        services.uptimeService.loadBalancer.servers = [
          {
            url = "http://127.0.0.1:27080";
          }
        ];
        routers.uptimeRouter = {
          entryPoints = ["websecure"];
          rule = "Host(`status.fschwickerath.de`)";
          service = "uptimeService";
          tls.certResolver = "resolver";
          middlewares = ["chainNoAuth"];
        };
      };
    };

    services.borgbackup.jobs.backup.paths = ["/var/lib/uptime-kuma/"];
    };
  };
}
