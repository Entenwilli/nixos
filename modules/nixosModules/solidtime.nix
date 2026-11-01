{...}: {
  flake.nixosModules.solidtime = {
    pkgs,
    lib,
    config,
    ...
  }: {
    options.solidtime.enable = lib.mkEnableOption "Enable solidtime";

    config = lib.mkIf config.solidtime.enable {
      sops.secrets."solidtime-env" = {
        restartUnits = [
          "docker-tracking-database.service"
          "docker-tracking-frontend.service"
          "docker-tracking-queue.service"
          "docker-tracking-scheduler.service"
        ];
      };

      services.traefik.dynamicConfigOptions = {
        http = {
          services.timeService.loadBalancer.servers = [
            {
              url = "http://127.0.0.1:8000";
            }
          ];
          routers.timeRouter = {
            entryPoints = ["websecure"];
            rule = "Host(`time.fschwickerath.de`)";
            service = "timeService";
            tls.certResolver = "resolver";
            middlewares = ["chainRequireAuth"];
          };
        };
      };

      virtualisation.docker = {
        enable = true;
        autoPrune.enable = true;
      };
      virtualisation.oci-containers.backend = "docker";

      virtualisation.oci-containers.containers."tracking-database" = {
        image = "postgres:15";
        environment = {
          "POSTGRES_DB" = "solidtime";
          "POSTGRES_USER" = "solidtime";
        };
        environmentFiles = [config.sops.secrets."solidtime-env".path];
        volumes = [
          "/srv/data/tracking/database:/var/lib/postgresql/data:rw"
        ];
        log-driver = "journald";
        extraOptions = [
          "--health-cmd=[\"pg_isready\", \"-q\", \"-d\", \"\", \"-U\", \"\"]"
          "--health-retries=3"
          "--health-timeout=5s"
          "--network-alias=tracking-database"
          "--network=internal"
        ];
      };
      systemd.services."docker-tracking-database" = {
        serviceConfig = {
          Restart = lib.mkOverride 90 "always";
          RestartMaxDelaySec = lib.mkOverride 90 "1m";
          RestartSec = lib.mkOverride 90 "100ms";
          RestartSteps = lib.mkOverride 90 9;
        };
        after = [
          "docker-network-internal.service"
        ];
        requires = [
          "docker-network-internal.service"
        ];
        partOf = [
          "docker-compose-solidtime-root.target"
        ];
        wantedBy = [
          "docker-compose-solidtime-root.target"
        ];
      };
      virtualisation.oci-containers.containers."tracking-frontend" = {
        image = "solidtime/solidtime:latest";
        environment = {
          "APP_DEBUG" = "false";
          "APP_ENV" = "production";
          "APP_FORCE_HTTPS" = "true";
          "APP_URL" = "https://time.fschwickerath.de";
          "AUTO_DB_MIGRATE" = "true";
          "CONTAINER_MODE" = "http";
          "DB_CONNECTION" = "pgsql";
          "DB_DATABASE" = "solidtime";
          "DB_HOST" = "tracking-database";
          "DB_PORT" = "5432";
          "DB_SSLMODE" = "require";
          "DB_USERNAME" = "solidtime";
          "FILESYSTEM_DISK" = "local";
          "GOTENBERG_URL" = "http://gotenberg:3000";
          "LOG_CHANNEL" = "stderr_daily";
          "LOG_LEVEL" = "debug";
          "MAIL_ENCRYPTION" = "tls";
          "MAIL_FROM_ADDRESS" = "no-reply@fschwickerath.de";
          "MAIL_FROM_NAME" = "solidtime";
          "MAIL_HOST" = "";
          "MAIL_MAILER" = "smtp";
          "MAIL_PASSWORD" = "";
          "MAIL_PORT" = "";
          "MAIL_USERNAME" = "";
          "PASSPORT_PUBLIC_KEY" = "-----BEGIN PUBLIC KEY-----\nMIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAqGzRZVIlGAU6Fn6T01a2\nvX2UovEQP5zXFBLtlgnrkR0SFx56IqSDYom+snpPPPk5A/sjB9hlQv3sJ9Moev2I\nUc68ZZrwK9oRBXArYCYUnDbA3sxxqH0yCcABkDUB1B/BjmkR8wUlDxVlG8sczYC6\nY5hqrH4IlZfjulp/MiczmTFJ7pFIH5FoHTJRVx0oWc4O4OInK8DmwuXGyL0gqPJy\n4Kho8/9/txXU0VZYmkaVuqdp5QKCX+NAohJbt+pZBdowVUMFC8qt/0S4F9ueziO3\nMEs6vASRlWeyN7OvwwyZw8HMRnBQikxCxmUBhpvSfnqu1723tzUsz36fodG6gjAt\nvikNerkwZ3BGivv8a1rdaS/3sUJa6CmYtHXWvNXWYNZpEgko4ZxyyL6kabYs2vua\ny/QNaGlqGkQrqsnTtGEhneqRW3maTvOyy9wFgtGNFxe/eq88kYPsYJCjbIWBvuZ/\nrIMXViqfEkDNxB+p7021f8v5W5MV5vur8aV1BRO/bXxh8qCn7frLF61x0wkYzJt4\njc95u/46uAdb6lNYQAbupWdzJV7Tlp/Tfru9YiJ4RfKC7xwg8tScNHwLDBhlf2DT\nkUrzM1DnjGBKfO5RchGJah+15l+xJOwQQmeJIsElL4yLkh3w+u4VkEdkCAOlWtDf\nHJLwxGT4hwjIm6glyHoJxP0CAwEAAQ==\n-----END PUBLIC KEY-----";
          "PUBLIC_FILESYSTEM_DISK" = "public";
          "QUEUE_CONNECTION" = "database";
          "SUPER_ADMINS" = "";
          "TRUSTED_PROXIES" = "0.0.0.0/0,2000:0:0:0:0:0:0:0/3";
        };
        environmentFiles = [config.sops.secrets."solidtime-env".path];
        volumes = [
          "/srv/data/tracking/app:/var/www/html/storage:rw"
          "/srv/data/tracking/app-storage:/var/www/html/storage/app:rw"
          "/srv/data/tracking/logs:/var/www/html/storage/logs:rw"
        ];
        dependsOn = [
          "tracking-database"
        ];
        user = "1000:1000";
        log-driver = "journald";
        ports = ["127.0.0.1:8000:8000"];
        extraOptions = [
          "--health-cmd=[\"curl\", \"--fail\", \"http://localhost:8000/health-check/up\"]"
          "--network-alias=timetracking"
          "--network=internal"
        ];
      };
      systemd.services."docker-tracking-frontend" = {
        serviceConfig = {
          Restart = lib.mkOverride 90 "always";
          RestartMaxDelaySec = lib.mkOverride 90 "1m";
          RestartSec = lib.mkOverride 90 "100ms";
          RestartSteps = lib.mkOverride 90 9;
        };
        after = [
          "docker-network-internal.service"
        ];
        requires = [
          "docker-network-internal.service"
        ];
        partOf = [
          "docker-compose-solidtime-root.target"
        ];
        wantedBy = [
          "docker-compose-solidtime-root.target"
        ];
      };
      virtualisation.oci-containers.containers."tracking-gotenberg" = {
        image = "gotenberg/gotenberg:8";
        log-driver = "journald";
        extraOptions = [
          "--health-cmd=[\"curl\", \"--silent\", \"--fail\", \"http://localhost:3000/health\"]"
          "--network-alias=gotenberg"
          "--network=internal"
        ];
      };
      systemd.services."docker-tracking-gotenberg" = {
        serviceConfig = {
          Restart = lib.mkOverride 90 "no";
        };
        after = [
          "docker-network-internal.service"
        ];
        requires = [
          "docker-network-internal.service"
        ];
        partOf = [
          "docker-compose-solidtime-root.target"
        ];
        wantedBy = [
          "docker-compose-solidtime-root.target"
        ];
      };
      virtualisation.oci-containers.containers."tracking-queue" = {
        image = "solidtime/solidtime:latest";
        environment = {
          "APP_DEBUG" = "false";
          "APP_ENV" = "production";
          "APP_FORCE_HTTPS" = "true";
          "APP_URL" = "https://time.fschwickerath.de";
          "CONTAINER_MODE" = "worker";
          "DB_CONNECTION" = "pgsql";
          "DB_DATABASE" = "solidtime";
          "DB_HOST" = "tracking-database";
          "DB_PORT" = "5432";
          "DB_SSLMODE" = "require";
          "DB_USERNAME" = "solidtime";
          "FILESYSTEM_DISK" = "local";
          "GOTENBERG_URL" = "http://gotenberg:3000";
          "LOG_CHANNEL" = "stderr_daily";
          "LOG_LEVEL" = "debug";
          "MAIL_ENCRYPTION" = "tls";
          "MAIL_FROM_ADDRESS" = "no-reply@your-domain.com";
          "MAIL_FROM_NAME" = "solidtime";
          "MAIL_HOST" = "";
          "MAIL_MAILER" = "smtp";
          "MAIL_PASSWORD" = "";
          "MAIL_PORT" = "";
          "MAIL_USERNAME" = "";
          "PASSPORT_PUBLIC_KEY" = "-----BEGIN PUBLIC KEY-----\nMIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAqGzRZVIlGAU6Fn6T01a2\nvX2UovEQP5zXFBLtlgnrkR0SFx56IqSDYom+snpPPPk5A/sjB9hlQv3sJ9Moev2I\nUc68ZZrwK9oRBXArYCYUnDbA3sxxqH0yCcABkDUB1B/BjmkR8wUlDxVlG8sczYC6\nY5hqrH4IlZfjulp/MiczmTFJ7pFIH5FoHTJRVx0oWc4O4OInK8DmwuXGyL0gqPJy\n4Kho8/9/txXU0VZYmkaVuqdp5QKCX+NAohJbt+pZBdowVUMFC8qt/0S4F9ueziO3\nMEs6vASRlWeyN7OvwwyZw8HMRnBQikxCxmUBhpvSfnqu1723tzUsz36fodG6gjAt\nvikNerkwZ3BGivv8a1rdaS/3sUJa6CmYtHXWvNXWYNZpEgko4ZxyyL6kabYs2vua\ny/QNaGlqGkQrqsnTtGEhneqRW3maTvOyy9wFgtGNFxe/eq88kYPsYJCjbIWBvuZ/\nrIMXViqfEkDNxB+p7021f8v5W5MV5vur8aV1BRO/bXxh8qCn7frLF61x0wkYzJt4\njc95u/46uAdb6lNYQAbupWdzJV7Tlp/Tfru9YiJ4RfKC7xwg8tScNHwLDBhlf2DT\nkUrzM1DnjGBKfO5RchGJah+15l+xJOwQQmeJIsElL4yLkh3w+u4VkEdkCAOlWtDf\nHJLwxGT4hwjIm6glyHoJxP0CAwEAAQ==\n-----END PUBLIC KEY-----";
          "PUBLIC_FILESYSTEM_DISK" = "public";
          "QUEUE_CONNECTION" = "database";
          "SUPER_ADMINS" = "";
          "TRUSTED_PROXIES" = "0.0.0.0/0,2000:0:0:0:0:0:0:0/3";
          "WORKER_COMMAND" = "php /var/www/html/artisan queue:work";
        };
        environmentFiles = [config.sops.secrets."solidtime-env".path];
        volumes = [
          "/srv/data/tracking/app:/var/www/html/storage:rw"
          "/srv/data/tracking/app-storage:/var/www/html/storage/app:rw"
          "/srv/data/tracking/logs:/var/www/html/storage/logs:rw"
        ];
        dependsOn = [
          "tracking-database"
        ];
        user = "1000:1000";
        log-driver = "journald";
        extraOptions = [
          "--health-cmd=[\"healthcheck\"]"
          "--network-alias=queue"
          "--network=internal"
        ];
      };
      systemd.services."docker-tracking-queue" = {
        serviceConfig = {
          Restart = lib.mkOverride 90 "always";
          RestartMaxDelaySec = lib.mkOverride 90 "1m";
          RestartSec = lib.mkOverride 90 "100ms";
          RestartSteps = lib.mkOverride 90 9;
        };
        after = [
          "docker-network-internal.service"
        ];
        requires = [
          "docker-network-internal.service"
        ];
        partOf = [
          "docker-compose-solidtime-root.target"
        ];
        wantedBy = [
          "docker-compose-solidtime-root.target"
        ];
      };
      virtualisation.oci-containers.containers."tracking-scheduler" = {
        image = "solidtime/solidtime:latest";
        environment = {
          "APP_DEBUG" = "false";
          "APP_ENV" = "production";
          "APP_FORCE_HTTPS" = "true";
          "APP_URL" = "https://time.fschwickerath.de";
          "CONTAINER_MODE" = "scheduler";
          "DB_CONNECTION" = "pgsql";
          "DB_DATABASE" = "solidtime";
          "DB_HOST" = "tracking-database";
          "DB_PORT" = "5432";
          "DB_SSLMODE" = "require";
          "DB_USERNAME" = "solidtime";
          "FILESYSTEM_DISK" = "local";
          "GOTENBERG_URL" = "http://gotenberg:3000";
          "LOG_CHANNEL" = "stderr_daily";
          "LOG_LEVEL" = "debug";
          "MAIL_ENCRYPTION" = "tls";
          "MAIL_FROM_ADDRESS" = "no-reply@your-domain.com";
          "MAIL_FROM_NAME" = "solidtime";
          "MAIL_HOST" = "";
          "MAIL_MAILER" = "smtp";
          "MAIL_PASSWORD" = "";
          "MAIL_PORT" = "";
          "MAIL_USERNAME" = "";
          "PASSPORT_PUBLIC_KEY" = "-----BEGIN PUBLIC KEY-----\nMIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAqGzRZVIlGAU6Fn6T01a2\nvX2UovEQP5zXFBLtlgnrkR0SFx56IqSDYom+snpPPPk5A/sjB9hlQv3sJ9Moev2I\nUc68ZZrwK9oRBXArYCYUnDbA3sxxqH0yCcABkDUB1B/BjmkR8wUlDxVlG8sczYC6\nY5hqrH4IlZfjulp/MiczmTFJ7pFIH5FoHTJRVx0oWc4O4OInK8DmwuXGyL0gqPJy\n4Kho8/9/txXU0VZYmkaVuqdp5QKCX+NAohJbt+pZBdowVUMFC8qt/0S4F9ueziO3\nMEs6vASRlWeyN7OvwwyZw8HMRnBQikxCxmUBhpvSfnqu1723tzUsz36fodG6gjAt\nvikNerkwZ3BGivv8a1rdaS/3sUJa6CmYtHXWvNXWYNZpEgko4ZxyyL6kabYs2vua\ny/QNaGlqGkQrqsnTtGEhneqRW3maTvOyy9wFgtGNFxe/eq88kYPsYJCjbIWBvuZ/\nrIMXViqfEkDNxB+p7021f8v5W5MV5vur8aV1BRO/bXxh8qCn7frLF61x0wkYzJt4\njc95u/46uAdb6lNYQAbupWdzJV7Tlp/Tfru9YiJ4RfKC7xwg8tScNHwLDBhlf2DT\nkUrzM1DnjGBKfO5RchGJah+15l+xJOwQQmeJIsElL4yLkh3w+u4VkEdkCAOlWtDf\nHJLwxGT4hwjIm6glyHoJxP0CAwEAAQ==\n-----END PUBLIC KEY-----";
          "PUBLIC_FILESYSTEM_DISK" = "public";
          "QUEUE_CONNECTION" = "database";
          "SUPER_ADMINS" = "";
          "TRUSTED_PROXIES" = "0.0.0.0/0,2000:0:0:0:0:0:0:0/3";
        };
        environmentFiles = [config.sops.secrets."solidtime-env".path];
        volumes = [
          "/srv/data/tracking/app:/var/www/html/storage:rw"
          "/srv/data/tracking/app-storage:/var/www/html/storage/app:rw"
          "/srv/data/tracking/logs:/var/www/html/storage/logs:rw"
        ];
        dependsOn = [
          "tracking-database"
        ];
        user = "1000:1000";
        log-driver = "journald";
        extraOptions = [
          "--health-cmd=[\"healthcheck\"]"
          "--network-alias=scheduler"
          "--network=internal"
        ];
      };
      systemd.services."docker-tracking-scheduler" = {
        serviceConfig = {
          Restart = lib.mkOverride 90 "always";
          RestartMaxDelaySec = lib.mkOverride 90 "1m";
          RestartSec = lib.mkOverride 90 "100ms";
          RestartSteps = lib.mkOverride 90 9;
        };
        after = [
          "docker-network-internal.service"
        ];
        requires = [
          "docker-network-internal.service"
        ];
        partOf = [
          "docker-compose-solidtime-root.target"
        ];
        wantedBy = [
          "docker-compose-solidtime-root.target"
        ];
      };

      # Networks
      systemd.services."docker-network-internal" = {
        path = [pkgs.docker];
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
          ExecStop = "docker network rm -f internal";
        };
        script = ''
          docker network inspect internal || docker network create internal --driver=bridge
        '';
        partOf = ["docker-compose-solidtime-root.target"];
        wantedBy = ["docker-compose-solidtime-root.target"];
      };

      systemd.targets."docker-compose-solidtime-root" = {
        unitConfig = {
          Description = "Root target generated by compose2nix.";
        };
        wantedBy = ["multi-user.target"];
      };

      services.borgbackup.jobs.backup.paths = ["/srv/data/tracking/"];
    };
  };
}
