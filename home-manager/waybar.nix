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
          modules-right = ["pulseaudio" "bluetooth" "network" "battery" "clock"];

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
            format = "{:%A %d.%m.%Y - %H:%M}";
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

        #clock, #battery, #backlight, #bluetooth, #network, #pulseaudio, #mpris{
          padding: 0 10px;
          margin: 0 5px;
        }

        #custom-launcher {
          background-color: #${config.colorScheme.palette.base02};
          padding: 0 0.5em;
          color: #7a95c9;
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
          color: #eb4d4b;
        }

        #mpris {
          color: #${config.colorscheme.palette.base0B};
          background: transparent;
        }



        #clock {
          color: #64727D;
        }

        #battery {
          color: #ffffff;
        }

        #battery.charging {
          color: #26A65B;
        }

        @keyframes blink {
          to {
            color: #ffffff;
          }
        }

        #battery.critical:not(.charging) {
          color: #f53c3c;
          animation-name: blink;
          animation-duration: 0.5s;
          animation-timing-function: linear;
          animation-iteration-count: infinite;
          animation-direction: alternate;
        }

        #backlight {
          color: #90b1b1;
        }

        #bluetooth.on {
          color: #68D2E8;
        }

        #bluetooth.connected {
          color: #6AA84F;
        }

        #network {
          color: #2980b9;
        }

        #network.disconnected {
          color: #f53c3c;
        }

        #pulseaudio {
          color: #f1c40f;
        }

        #pulseaudio.muted {
          color: #90b1b1;
        }
      '';
    };
  };
}
