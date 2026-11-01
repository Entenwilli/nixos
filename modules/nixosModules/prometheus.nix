{...}: {
  flake.nixosModules.prometheus = {
    config,
    lib,
    ...
  }: {
    options.prometheus.enable = lib.mkEnableOption "Enable prometheus";

    config = lib.mkIf config.prometheus.enable {
      services.prometheus.exporters.node = {
        enable = true;
        listenAddress = "127.0.0.1";
        port = 9100;
      };

      services.prometheus = {
        enable = true;
        port = 9090;
        listenAddress = "127.0.0.1";
        scrapeConfigs = [
          {
            job_name = "traefik";
            static_configs = [
              {
                targets = ["127.0.0.1:8082"];
              }
            ];
          }
          {
            job_name = "node";
            static_configs = [
              {
                targets = ["127.0.0.1:9100"];
              }
            ];
          }
        ];
      };

      services.borgbackup.jobs.backup.paths = ["/var/lib/prometheus2/"];
    };
  };
}
