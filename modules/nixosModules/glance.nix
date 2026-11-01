{...}: {
  flake.nixosModules.glance = {
    config,
    lib,
    ...
  }: {
    options.glance.enable = lib.mkEnableOption "Enable glance";

    config = lib.mkIf config.glance.enable {
    sops.secrets."glance-auth-secret-key" = {};
    sops.secrets."glance-felix-password" = {};

    services.glance = {
      enable = true;
      settings = {
        server.host = "127.0.0.1";
        server.port = 27557;
        pages = [
          {
            name = "Home";
            hide-desktop-navigation = true;
            columns = [
              {
                size = "small";
                widgets = [
                  {
                    type = "calendar";
                    first-day-of-week = "monday";
                  }
                  {
                    type = "server-stats";
                    servers = [
                      {
                        type = "local";
                        name = "NixOS-Server";
                      }
                    ];
                  }
                  {
                    type = "twitch-channels";
                    channels = [
                      "Vedal987"
                      "ellie_minibot"
                    ];
                  }
                ];
              }
              {
                size = "full";
                widgets = [
                  {
                    type = "bookmarks";
                    groups = [
                      {
                        links = [
                          {
                            title = "GitHub";
                            icon = "si:github";
                            url = "https://github.com/Entenwilli";
                          }
                          {
                            title = "Calendar";
                            icon = "si:googlecalendar";
                            url = "https://calendar.google.com";
                          }
                          {
                            title = "Notes";
                            icon = "si:obsidian";
                            url = "obsidian://open?vault=Notes&file=00%20-%20Home%2FHome";
                            target = "_self";
                          }
                        ];
                      }
                      {
                        links = [
                          {
                            title = "Wanikani";
                            icon = "mdi:ideogram-cjk";
                            url = "https://wanikani.com";
                          }
                          {
                            title = "Telekom E-Mail";
                            icon = "si:deutschetelekom";
                            url = "https://email.t-online.de";
                          }
                          {
                            title = "Selfhosted E-Mail";
                            icon = "mdi:email-multiple";
                            url = "https://box.fschwickerath.de/mail";
                          }
                        ];
                      }
                      {
                        title = "Selfhosted";
                        color = "200 50 50";
                        links = [
                          {
                            title = "Bookmarks";
                            icon = "mdi:bookmark-box-multiple";
                            url = "https://bookmarks.fschwickerath.de";
                          }
                          {
                            title = "Time Tracking";
                            icon = "mdi:clock";
                            url = "https://time.fschwickerath.de";
                          }
                        ];
                      }
                      {
                        title = "KIT";
                        color = "172 100 58";
                        links = [
                          {
                            title = "Illias";
                            icon = "mdi:school";
                            url = "https://illias.studium.kit.edu";
                          }
                          {
                            title = "Campus";
                            icon = "mdi:account-box";
                            url = "https://campus.studium.kit.edu";
                          }
                          {
                            title = "KIT E-Mail";
                            icon = "mdi:email";
                            url = "https://owa.kit.edu";
                          }
                        ];
                      }
                    ];
                  }
                  {
                    type = "rss";
                    limit = 10;
                    collapse-after = 5;
                    cache = "12h";
                    style = "detailed-list";
                    feeds = [
                      {
                        url = "https://www.tagesschau.de/index~rss2.xml";
                        title = "Tagesschau";
                        limit = 3;
                      }
                      {
                        url = "https://rss.nebula.app/video/channels/jetlag.rss";
                        title = "Nebula - JetLag The Game";
                        limit = 1;
                      }
                      {
                        url = "https://rss.nebula.app/video/channels/sebastianlague.rss";
                        title = "Nebula - Sebastian Lague";
                        limit = 1;
                      }
                      {
                        url = "https://rss.nebula.app/video/channels/notjustbikes.rss";
                        title = "Nebula - Not Just Bikes";
                        limit = 1;
                      }
                    ];
                  }
                  {
                    type = "videos";
                    channels = [
                      "UCHL9bfHTxCMi-7vfxQ-AYtg" # Abroad in Japan
                      "UCUMwY9iS8oMyWDYIe6_RmoA" # No Boilerplate
                      "UC2C_jShtL725hvbm1arSV9w" # CGP Grey
                      "UC-MNe3ago8Tp1C-YwpVJS8Q" # Tanner
                      "UCPsZ_0SkFdi551iYTG04R2g" # CDawgVA
                      "UCoil_VoKvJY4kdlBOZv974w" # ConnorDawg
                      "UCLHmLrj4pHHg3-iBJn_CqxA" # Neuro-sama
                      "UC7zq5pBOUDf-xykfDgBwW2w" # Trenton
                      "UC1fKT0wuhchtclPqpdWEnHw" # NeverKnowsBest
                      "UCUkRj4qoT1bsWpE_C8lZYoQ" # ThinMatrix
                    ];
                  }
                ];
              }
              {
                size = "small";
                widgets = [
                  {
                    type = "weather";
                    location = "Karlsruhe, Germany";
                    units = "metric";
                    hour-format = "24h";
                  }
                  {
                    type = "releases";
                    cache = "1d";
                    repositories = [
                      "glanceapp/glance"
                      "syncthing/syncthing"
                    ];
                  }
                ];
              }
            ];
          }
        ];

        auth = {
          secret-key = {_secret = config.sops.secrets."glance-auth-secret-key".path;};
          users.felix.password = {_secret = config.sops.secrets."glance-felix-password".path;};
        };

        server.proxied = true;

        theme = {
          background-color = "240 21 15";
          contrast-multiplier = 1.2;
          primary-color = "217 92 83";
          positive-color = "115 54 76";
          negative-color = "347 70 65";
        };
      };
    };

    services.traefik.dynamicConfigOptions = {
      http = {
        services.dashboardService.loadBalancer.servers = [
          {
            url = "http://127.0.0.1:27557";
          }
        ];
        routers.dashboardRouter = {
          entryPoints = ["websecure"];
          rule = "Host(`dashboard.fschwickerath.de`)";
          service = "dashboardService";
          tls.certResolver = "resolver";
          middlewares = ["chainNoAuth"];
        };
      };
    };

    services.borgbackup.jobs.backup.paths = ["/var/lib/glance/"];
    };
  };
}
