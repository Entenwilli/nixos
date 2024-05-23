{
  lib,
  pkgs,
  config,
  inputs,
  ...
}: {
  options = {
    waybar.enable = lib.mkEnableOption "Enable waybar";
  };

  config = lib.mkIf config.waybar.enable {
    programs.waybar = {
      enable = true;
      systemd.enable = true;
      package = pkgs.unstable.waybar;
      settings = {
        main = {
          layer = "top";
          position = "top";
          height = 30;
          output = [
            "eDP-1"
            "DP-1"
          ];
          modules-left = ["custom/launcher" "hyprland/workspaces" "mpris"];
          # modules-center = ["hyprland/window"];
          modules-right = ["backlight" "pulseaudio" "bluetooth" "network" "battery" "clock"];

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
            format = " {title} - {artist} [{position}/{length}]";
            interval = 3;
          };
          "hyprland/window" = {
          };
          "backlight" = {
            format = "{percent}% {icon}";
            format-icons = ["󰃚" "󰃛" "󰃜" "󰃝" "󰃞" "󰃟" "󰃠"];
          };
          "pulseaudio" = {
            format = "{volume}% {icon}";
            format-muted = "0% ";
            format-icons = ["" "" ""];
          };
          "bluetooth" = {
            format = " {status}";
            format-connected = " {device_alias}";
            format-connected-battery = " {device_alias} {device_battery_percentage}%";
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
            format-icons = ["󰁹" "󰂂" "󰂁" "󰂀" "󰁿" "󰁾" "󰁽" "󰁼" "󰁻" "󰁺"];
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
                days = "<span color='#${config.colorScheme.palette.base05}'><b>{}</b></span>";
                weeks = "<span color='#${config.colorScheme.palette.base09}'><b>W{:%W}</b></span>";
                weekdays = "<span color='#${config.colorScheme.palette.base05}'><b>{}</b></span>";
                today = "<span color='#${config.colorScheme.palette.base08}'><b><u>{}</u></b></span>";
              };
            };
          };
        };
      };
      style = ''
        * {
          border: none;
          border-radius: 0;
          font-family: FiraCode Nerd Font;
          font-size: 13px;
          min-height: 0;
        }

        window#waybar {
          background-color: rgba(${inputs.nix-colors.lib.conversions.hexToRGBString "," config.colorScheme.palette.base01}, 0.7);
          color: #ffffff;
        }

        #custom-launcher {
          color: #7a95c9;
          background-color: #${config.colorScheme.palette.base02};
          padding: 0 0.5em;
          margin-left: 0.5em;
          font-size: 25px;
          border-top-left-radius: 0.5em;
          border-bottom-left-radius: 0.5em;
        }

        #workspaces {
          background-color: #${config.colorScheme.palette.base02};
          border-top-right-radius: 0.5em;
          border-bottom-right-radius: 0.5em;
        }

        #workspaces button {
          padding: 0 0.5em;
          color: #FFFFFF;
          margin: 0.25em;
        }

        #workspaces button.active {
          color: #${config.colorScheme.palette.base0B};
          font-weight: 700;
        }

        #workspaces button.urgent {
          color: #${config.colorScheme.palette.base08};
        }

        #mpris {
          color: #${config.colorScheme.palette.base0B};
          background: transparent;
        }


        #backlight {
          color: #${config.colorScheme.palette.base09};
          background-color: #${config.colorScheme.palette.base02};
          padding: 0 0.5em;
          border-top-left-radius: 0.5em;
          border-bottom-left-radius: 0.5em;
        }

        #pulseaudio {
          color: #${config.colorScheme.palette.base0C};
          background-color: #${config.colorScheme.palette.base02};
          padding: 0 0.5em;
          border-top-right-radius: 0.5em;
          border-bottom-right-radius: 0.5em;
        }

        #pulseaudio.muted {
          color: #${config.colorScheme.palette.base06};
        }



        #bluetooth {
          color: #${config.colorScheme.palette.base06};
          background-color: #${config.colorScheme.palette.base02};
          padding: 0 0.5em;
          border-top-left-radius: 0.5em;
          border-bottom-left-radius: 0.5em;
          margin-left: 2em;
        }

        #bluetooth.on {
          color: #${config.colorScheme.palette.base0E};
        }

        #bluetooth.connected {
          color: #${config.colorScheme.palette.base0B};
        }

        #network {
          color: #${config.colorScheme.palette.base0A};
          background-color: #${config.colorScheme.palette.base02};
          padding: 0 0.5em;
          border-top-right-radius: 0.5em;
          border-bottom-right-radius: 0.5em;
        }

        #network.disconnected {
          color: #f53c3c;
        }



        #battery {
          color: #${config.colorScheme.palette.base05};
          background-color: #${config.colorScheme.palette.base02};
          padding: 0 0.5em;
          margin-left: 2em;
          margin-right: 0px;
          border-top-left-radius: 0.5em;
          border-bottom-left-radius: 0.5em;
        }

        #battery.charging {
          color: #${config.colorScheme.palette.base0B};
        }

        @keyframes blink {
          to {
            color: #ffffff;
          }
        }

        #battery.critical:not(.charging) {
          color: #${config.colorScheme.palette.base08};
          animation-name: blink;
          animation-duration: 0.5s;
          animation-timing-function: linear;
          animation-iteration-count: infinite;
          animation-direction: alternate;
        }


        #clock {
          color: #${config.colorScheme.palette.base0D};
          background-color: #${config.colorScheme.palette.base02};
          padding: 0px 0.5em;
          margin-left: 0px;
          margin-right: 0.5em;
          border-top-right-radius: 0.5em;
          border-bottom-right-radius: 0.5em;
        }
      '';
    };
  };
}
