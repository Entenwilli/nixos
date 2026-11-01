{...}: {
  flake.nixosModules.ntfy = {
    config,
    lib,
    ...
  }: {
    options.ntfy.enable = lib.mkEnableOption "Enable ntfy";

    config = lib.mkIf config.ntfy.enable {
    services.ntfy-sh = {
      enable = true;
      settings.base-url = "https://notifications.fschwickerath.de";
      settings.behind-proxy = true;
      settings.listen-http = ":28982";
    };

    services.traefik.dynamicConfigOptions = {
      http = {
        services.notificationService.loadBalancer.servers = [
          {
            url = "http://127.0.0.1:28982";
          }
        ];
        routers.notificationRouter = {
          entryPoints = ["websecure"];
          rule = "Host(`notifications.fschwickerath.de`)";
          service = "notificationService";
          tls.certResolver = "resolver";
          middlewares = ["chainNoAuth"];
        };
      };
    };

    services.borgbackup.jobs.backup.paths = ["/var/lib/ntfy-sh/"];
    };
  };
}
