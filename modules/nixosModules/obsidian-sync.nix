{...}: {
  flake.nixosModules.obsidian-sync = {
    config,
    lib,
    ...
  }: {
    options."obsidian-sync".enable = lib.mkEnableOption "Enable obsidian-sync";

    config = lib.mkIf config."obsidian-sync".enable {
      sops.secrets."couchdb-admin-config" = {
        owner = "couchdb";
        group = "couchdb";
        restartUnits = ["couchdb.service"];
      };

      services.couchdb = {
        enable = true;
        adminUser = "felix";
        bindAddress = "127.0.0.1";
        port = 5984;
        extraConfigFiles = [config.sops.secrets."couchdb-admin-config".path];
        extraConfig = {
          chttpd = {
            require_valid_user = true;
            enable_cors = true;
            max_http_request_size = 4294967296;
          };
          chttpd_auth = {
            require_valid_user = true;
          };
          httpd = {
            WWW-Authenticate = "Basic realm=\"couchdb\"";
            enable_cors = true;
          };
          couchdb = {
            single_node = true;
            max_document_size = 50000000;
          };
          cors = {
            credentials = true;
            origins = "app://obsidian.md,capacitor://localhost,http://localhost";
          };
        };
      };

      services.traefik.dynamicConfigOptions = {
        http = {
          middlewares.obsidianCORS.headers = {
            accesscontrolallowmethods = "GET,PUT,POST,HEAD,DELETE,OPTIONS";
            accesscontrolallowheaders = "accept, authorization, content-type,origin,referer";
            accesscontrolalloworiginlist = "app://obsidian.md,capacitor://localhost,http://localhost";
            accesscontrolmaxage = 3600;
            addvaryheader = true;
            accessControlAllowCredentials = true;
          };

          services.obsidianSyncService.loadBalancer.servers = [
            {
              url = "http://127.0.0.1:5984";
            }
          ];
          routers.obsidianSyncRouterRouter = {
            entryPoints = ["websecure"];
            rule = "Host(`obsidian-sync.fschwickerath.de`)";
            service = "obsidianSyncService";
            tls.certResolver = "resolver";
            middlewares = ["obsidianCORS"];
          };
        };
      };

      services.borgbackup.jobs.backup.paths = ["/var/lib/couchdb/"];
    };
  };
}
