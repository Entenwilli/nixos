{...}: {
  flake.nixosModules.traefik = {
    config,
    lib,
    ...
  }: {
    options.traefik.enable = lib.mkEnableOption "Enable traefik";

    config = lib.mkIf config.traefik.enable {
      sops.secrets."traefik-basic-auth" = {
        owner = "traefik";
        restartUnits = ["traefik.service"];
      };

      services.traefik = {
        enable = true;

        staticConfigOptions = {
          entryPoints = {
            web = {
              address = ":80";
              asDefault = true;
              http.redirections.entrypoint = {
                to = "websecure";
                scheme = "https";
              };
            };

            websecure = {
              address = ":443";
              asDefault = true;
              http.tls.certResolver = "resolver";
              transport.respondingTimeouts.readTimeout = 0;
            };

            metrics.address = "127.0.0.1:8082";
          };

          accessLog = {
            format = "common";
            fields = {
              defaultMode = "keep";
              headers.defaultMode = "keep";
            };
          };

          log = {
            level = "TRACE";
            filePath = "${config.services.traefik.dataDir}/traefik.log";
            format = "json";
          };

          certificatesResolvers.resolver.acme = {
            email = "admin@fschwickerath.de";
            storage = "${config.services.traefik.dataDir}/acme.json";
            tlsChallenge = {};
          };

          api.dashboard = true;

          metrics.prometheus = {
            entryPoint = "metrics";
            addEntryPointsLabels = true;
            addRoutersLabels = true;
            addServicesLabels = true;
          };
        };

        dynamicConfigOptions = {
          http.routers.dashboard = {
            entryPoints = ["websecure"];
            rule = "Host(`traefik.fschwickerath.de`)";
            service = "api@internal";
            tls.certResolver = "resolver";
            middlewares = ["chainRequireAuth"];
          };

          http.middlewares = {
            secureHeaders.headers = {
              accessControlAllowMethods = ["GET" "PUT" "OPTIONS"];
              accessControlMaxAge = 100;
              hostsProxyHeaders = ["X-Forwarded-Host" "X-Forwarded-For"];
              stsSeconds = 63072000;
              stsIncludeSubdomains = true;
              stsPreload = true;
              forceSTSHeader = true;
              customFrameOptionsValue = "allow-from https:fschwickerath.de";
              contentTypeNosniff = true;
              browserXssFilter = true;
              referrerPolicy = "same-origin";
              permissionsPolicy = "camera=(), microphone=(), geolocation=(), payment=(), usb=(), vr=()";
              contentSecurityPolicy = "frame-ancestors '*.fschwickerath.de:*';object-src 'none';";
              customResponseHeaders = {
                X-Robots-Tag = "none,noarchive,nosnippet,notranslate,noimageindex,";
                server = "";
                X-Forwarded-Proto = "https";
              };
            };

            rateLimiting = {
              rateLimit = {
                average = 250;
                burst = 50;
              };
            };

            redirectToHTTPS = {
              redirectScheme = {
                scheme = "https";
                permanent = true;
              };
            };

            compressTraffic = {
              compress = {};
            };

            auth = {
              basicAuth = {
                usersFile = config.sops.secrets."traefik-basic-auth".path;
              };
            };

            chainNoAuth = {
              chain = {
                middlewares = [
                  "rateLimiting"
                  "redirectToHTTPS"
                  "secureHeaders"
                  "compressTraffic"
                ];
              };
            };

            chainRequireAuth = {
              chain = {
                middlewares = [
                  "rateLimiting"
                  "redirectToHTTPS"
                  "auth"
                  "secureHeaders"
                  "compressTraffic"
                ];
              };
            };
          };
        };
      };

      services.borgbackup.jobs.backup.paths = ["/var/lib/traefik/"];
    };
  };
}
