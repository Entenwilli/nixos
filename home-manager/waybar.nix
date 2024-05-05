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
    programs.waybar = {
      enable = true;
      systemd.enable = true;
      settings = {
        main = {
          layer = "top";
          position = "top";
          height = 30;
          output = [
            "eDP-1"
            "HDMI-A-1"
          ];
          modules-left = ["custom/launcher" "hyprland/workspaces" "mpris"];
          # modules-center = ["hyprland/window"];
          modules-right = ["pulseaudio" "bluetooth" "network" "battery" "clock"];

          "custom/launcher" = {
            format = "󱄅";
            on-click = "${pkgs.rofi-wayland}/bin/rofi -show drun";
          };
          "hyprland/workspaces" = {
            format = "{name}: {icon}";
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
                  background: rgba(43, 48, 59, 0.5);
                  border-bottom: 3px solid rgba(100, 114, 125, 0.5);
                  color: #ffffff;
                }

                #workspaces button {
                  padding: 0 12px;
                  background: transparent;
                  color: #FFFFFF;
                  border-bottom: 3px solid transparent;
                }
        #workspaces button.active {
                  background: #64727D;
                  border-bottom: 3px solid #ffffff;
              }

        #workspaces button.urgent {
                  background-color: #eb4d4b;
              }

        #clock, #battery, #backlight, #bluetooth, #network, #pulseaudio, #mpris, #custom-launcher {
                  padding: 0 10px;
                  margin: 0 5px;
              }

        #clock {
                  background-color: #64727D;
              }

        #battery {
                  background-color: #ffffff;
                  color: #000000;
              }

        #battery.charging {
                  color: #ffffff;
                  background-color: #26A65B;
              }

              @keyframes blink {
                  to {
                      background-color: #ffffff;
                      color: #000000;
                  }
              }

        #battery.critical:not(.charging) {
                  background: #f53c3c;
                  color: #ffffff;
                  animation-name: blink;
                  animation-duration: 0.5s;
                  animation-timing-function: linear;
                  animation-iteration-count: infinite;
                  animation-direction: alternate;
              }

        #backlight {
                  background: #90b1b1;
              }

        #network {
                  background: #2980b9;
              }

        #network.disconnected {
                  background: #f53c3c;
              }

        #pulseaudio {
                  background: #f1c40f;
                  color: #000000;
              }

        #pulseaudio.muted {
                  background: #90b1b1;
                  color: #2a5c45;
              }

        #mpris {
                  background: #66cc99;
                  color: #2a5c45;
              }

        #custom-launcher {
            background: #9b59b6;
            font-size: 20px;
            padding: 0 15px;
          }
      '';
    };
  };
}
