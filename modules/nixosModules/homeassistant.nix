{...}: {
  flake.nixosModules.homeassistant = {
    pkgs,
    config,
    lib,
    ...
  }: {
    options.homeassistant.enable = lib.mkEnableOption "Enable homeassistant";

    config = lib.mkIf config.homeassistant.enable {
    sops.secrets."mosquitto-felix-hashed-password" = {
      owner = "mosquitto";
      restartUnits = ["mosquitto.service"];
    };

    services.mosquitto = {
      enable = true;
      listeners = [
        {
          users.felix = {
            acl = ["readwrite #"];
            hashedPasswordFile = config.sops.secrets."mosquitto-felix-hashed-password".path;
          };
        }
      ];
    };
    networking.firewall.allowedTCPPorts = [1883];

    services.home-assistant = {
      enable = true;
      config = {
        frontend.themes = "!include_dir_merge_named themes";
        http = {
          server_host = ["127.0.0.1"];
          server_port = 8123;
          trusted_proxies = ["127.0.0.1"];
          use_x_forwarded_for = true;
        };
        default_config = {};
        "automation ui" = "!include automations.yaml";
        "scene ui" = "!include scenes.yaml";
        "script ui" = "!include scripts.yaml";
      };
      customComponents = with pkgs.home-assistant-custom-components; [
        dwd
      ];
      extraComponents = [
        "isal"
        "spotify"
        "mobile_app"
        "ntfy"
        "syncthing"
        "google_translate"
        "met"
        "github"
        "mqtt"
        "remote_calendar"
        "dwd_weather_warnings"
      ];
      configWritable = true;
      openFirewall = true;
    };

    services.traefik.dynamicConfigOptions = {
      http = {
        services.homeassistantService.loadBalancer.servers = [
          {
            url = "http://127.0.0.1:8123";
          }
        ];
        routers.homeassistantRouter = {
          entryPoints = ["websecure"];
          rule = "Host(`homeassistant.fschwickerath.de`)";
          service = "homeassistantService";
          tls.certResolver = "resolver";
          middlewares = ["chainNoAuth"];
        };
      };
    };
    };
  };
}
