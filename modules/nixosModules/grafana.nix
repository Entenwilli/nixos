{...}: {
  flake.nixosModules.grafana = {
    config,
    lib,
    ...
  }: {
    options.grafana.enable = lib.mkEnableOption "Enable grafana";

    config = lib.mkIf config.grafana.enable {
      sops.secrets."grafana-admin-password" = {
        owner = "grafana";
        restartUnits = ["grafana.service"];
      };
      sops.secrets."grafana-secret-key" = {
        owner = "grafana";
        restartUnits = ["grafana.service"];
      };

      services.grafana = {
        enable = true;
        settings = {
          server = {
            http_addr = "127.0.0.1";
            http_port = 27558;
            domain = "grafana.fschwickerath.de";
            root_url = "https://grafana.fschwickerath.de/";
          };
          security = {
            admin_user = "felix";
            admin_password = "$__file{${config.sops.secrets."grafana-admin-password".path}}";
            secret_key = "$__file{${config.sops.secrets."grafana-secret-key".path}}";
          };
        };

        provision = {
          enable = true;

          datasources.settings = {
            apiVersion = 1;
            datasources = [
              {
                name = "Prometheus";
                type = "prometheus";
                access = "proxy";
                url = "http://127.0.0.1:9090";
                isDefault = true;
              }
            ];
          };

          alerting.contactPoints.settings = {
            apiVersion = 1;
            contactPoints = [
              {
                orgId = 1;
                name = "ntfy";
                receivers = [
                  {
                    uid = "ntfy-webhook";
                    type = "webhook";
                    settings.url = "http://127.0.0.1:27559";
                  }
                ];
              }
            ];
          };
        };
      };

      services.grafana-to-ntfy = {
        enable = true;
        settings = {
          address = "127.0.0.1";
          port = 27559;
          ntfyUrl = "https://notifications.fschwickerath.de/grafana-alerts";
        };
      };

      services.traefik.dynamicConfigOptions = {
        http = {
          services.grafanaService.loadBalancer.servers = [
            {
              url = "http://127.0.0.1:27558";
            }
          ];
          routers.grafanaRouter = {
            entryPoints = ["websecure"];
            rule = "Host(`grafana.fschwickerath.de`)";
            service = "grafanaService";
            tls.certResolver = "resolver";
            middlewares = ["chainNoAuth"];
          };
        };
      };

      services.borgbackup.jobs.backup.paths = ["/var/lib/grafana/"];
    };
  };
}
