{
  lib,
  pkgs,
  config,
  ...
}: {
  options = {
    waybar.enable = lib.mkEnableOption "Enable waybar";
  };

  config = lib.mkIf config.waybar.enable {
    home.packages = with pkgs; [
      wttrbar
    ];

    programs.waybar = {
      enable = true;
      systemd.enable = true;
      package = pkgs.waybar;
      settings = {
        main = {
          layer = "top";
          position = "top";
          height = 0;
          margin-top = 10;
          margin-left = 10;
          margin-right = 10;
          output = [
            "eDP-1"
            "DP-1"
            "DP-3"
          ];
          modules-left = ["custom/launcher" "hyprland/workspaces"];
          modules-center = ["mpris"];
          modules-right = ["custom/weather" "backlight" "pulseaudio" "bluetooth" "network" "battery" "clock"];

          "custom/launcher" = {
            format = "󱄅";
            on-click = "${pkgs.rofi-wayland}/bin/rofi -show drun";
          };
          "hyprland/workspaces" = {
            format = "{icon}";
            format-icons = {
              "1" = "";
              "2" = "󰈹";
              "3" = "";
              "4" = "";
              "5" = "";
              "default" = "";
            };
            persistent-workspaces = {
              "*" = 5;
            };
          };
          "mpris" = {
            format = " {title} - {artist}";
            interval = 3;
            dynamic-len = 20;
          };
          "hyprland/window" = {
          };
          "custom/weather" = {
            tooltip = true;
            format = "{}";
            interval = 30;
            exec = "${pkgs.wttrbar}/bin/wttrbar --custom-indicator \"{ICON} {temp_C}°\"";
            return-type = "json";
          };
          "backlight" = {
            format = "{percent}% {icon}";
            format-icons = ["󰃚" "󰃛" "󰃜" "󰃝" "󰃞" "󰃟" "󰃠"];
          };
          "pulseaudio" = {
            format = "{volume}% {icon}";
            format-muted = "0% 󰝟 ";
            format-icons = ["" " " " " ""];
          };
          "bluetooth" = {
            format = " {status}";
            format-connected = " {device_alias}";
            format-connected-battery = " {device_alias} | {device_battery_percentage}%";
            on-click = "DMENU_BLUETOOTH_LAUNCHER=\"rofi\" ${pkgs.dmenu-bluetooth}/bin/dmenu-bluetooth&";
          };
          "network" = {
            format-wifi = "{essid}  ";
            format-disconnected = "Offline 󱚼 ";
            on-click = "${pkgs.networkmanager_dmenu}/bin/networkmanager_dmenu&";
          };
          "battery" = {
            interval = 60;
            states = {
              warning = 30;
              critical = 15;
            };
            format = "{capacity}% {icon}";
            format-icons = ["󰁺" "󰁻" "󰁻" "󰁻" "󰁼" "󰁽" "󰁾" "󰁿" "󰂀" "󰂁" "󰂂" "󰁹"];
            format-charging = "{capacity}% 󰂄";
          };
          "clock" = {
            interval = 60;
            format = "{:%a %d.%m.%Y - %H:%M}";
            tooltip-format = "<tt><small>{calendar}</small></tt>";
            calendar = {
              mode = "month";
              weeks-pos = "left";
              on-scroll = 1;
              format = {
                days = "<span color='#${config.scheme.base05}'><b>{}</b></span>";
                weeks = "<span color='#${config.scheme.base09}'><b>W{:%W}</b></span>";
                weekdays = "<span color='#${config.scheme.base05}'><b>{}</b></span>";
                today = "<span color='#${config.scheme.base08}'><b><u>{}</u></b></span>";
              };
            };
          };
        };
      };
      style = let
        margin = "0 0.5em";
      in ''
        * {
          border: none;
          border-radius: 0;
          font-family: FiraCode Nerd Font;
          font-size: 11px;
          min-height: 0;
        }

        window#waybar {
          color: ${config.scheme.withHashtag.base06};
          background-color: transparent;
        }

        #custom-launcher {
          background-color: ${config.scheme.withHashtag.base0D};
          color: #${config.scheme.base02};
          padding: 0 0.5em;
          margin-left: 0.5em;
          font-size: 20px;
          border-top-left-radius: 0.5em;
          border-bottom-left-radius: 0.5em;
        }

        #workspaces {
          background-color: #${config.scheme.base02};
          border-top-right-radius: 0.5em;
          border-bottom-right-radius: 0.5em;
        }

        #workspaces button {
          padding: 0 0.5em;
          color: #FFFFFF;
          margin: 0.25em;
        }

        #workspaces button.active {
          color: #${config.scheme.base0B};
          font-weight: 700;
        }

        #workspaces button.urgent {
          color: #${config.scheme.base08};
        }

        #mpris{
          background-color: #${config.scheme.base0B};
          color: #${config.scheme.base02};
          padding: 0.5em;
          border-radius: 0.5em;
          margin: ${margin};
        }

        #custom-weather {
          background-color: #${config.scheme.base0D};
          color: #${config.scheme.base02};
          padding: 0 0.5em;
          border-radius: 0.5em;
          margin: ${margin};
        }

        #backlight {
          background-color: #${config.scheme.base09};
          color: #${config.scheme.base02};
          padding: 0 0.5em;
          border-radius: 0.5em;
          margin: ${margin};
        }

        #pulseaudio {
          background-color: #${config.scheme.base0C};
          color: #${config.scheme.base02};
          padding: 0 0.5em;
          border-radius: 0.5em;
          margin: ${margin};
        }

        #pulseaudio.muted {
          background-color: #${config.scheme.base06};
        }



        #bluetooth {
          background-color: #${config.scheme.base06};
          color: #${config.scheme.base02};
          padding: 0 0.5em;
          border-radius: 0.5em;
          margin: ${margin};
        }

        #bluetooth.on {
          background-color: #${config.scheme.base0E};
        }

        #bluetooth.connected {
          background-color: #${config.scheme.base0B};
        }

        #network {
          background-color: #${config.scheme.base0A};
          color: #${config.scheme.base02};
          padding: 0 0.5em;
          border-radius: 0.5em;
          margin: ${margin};
        }

        #network.disconnected {
          background-color: #f53c3c;
        }

        #battery {
          background-color: #${config.scheme.base05};
          color: #${config.scheme.base02};
          padding: 0 0.5em;
          border-radius: 0.5em;
          margin: ${margin};
        }

        #battery.charging {
          background-color: #${config.scheme.base0B};
        }

        @keyframes blink {
          to {
            color: #ffffff;
          }
        }

        #battery.warning:not(.charging) {
          background-color: ${config.scheme.withHashtag.base0A};
        }

        #battery.critical:not(.charging) {
          background-color: #${config.scheme.base08};
          animation-name: blink;
          animation-duration: 0.5s;
          animation-timing-function: linear;
          animation-iteration-count: infinite;
          animation-direction: alternate;
        }


        #clock {
          background-color: #${config.scheme.base0D};
          color: #${config.scheme.base02};
          padding: 0px 0.5em;
          margin: ${margin};
          border-radius: 0.5em;
        }
      '';
    };
  };
}
