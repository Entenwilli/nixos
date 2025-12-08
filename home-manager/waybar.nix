{
  lib,
  pkgs,
  config,
  ...
}: let
  typing = pkgs.writeShellApplication {
    name = "typing";

    text = ''
      value=$(fcitx5-remote -n)

      if [ "$value" == "keyboard-us" ]; then
        hyprctl devices -j | jq -r '.keyboards[] | .layout' | head -n1
      elif [ "$value" == "mozc" ]; then
        echo "jp"
      fi
    '';
  };
in {
  options = {
    waybar.enable = lib.mkEnableOption "Enable waybar";
  };

  config = lib.mkIf config.waybar.enable {
    home.packages = with pkgs; [
      wttrbar
      pavucontrol
      jq
    ];

    programs.waybar = {
      enable = true;
      systemd.enable = true;
      package = pkgs.waybar;
      settings = {
        main = {
          layer = "top";
          position = "top";
          height = 10;
          output = [
            "eDP-1"
            "DP-1"
            "DP-2"
            "DP-3"
            "HDMI-A-1"
          ];
          modules-left = ["group/pill-left"];
          modules-center = ["group/pill-center"];
          modules-right = ["group/pill-right"];

          "group/pill-workspaces" = {
            orientation = "inherit";
            modules = ["custom/launcher" "hyprland/workspaces"];
          };

          "group/pill-media-time" = {
            orientation = "inherit";
            modules = ["clock" "mpris"];
          };

          "group/pill-left" = {
            "orientation" = "inherit";
            "modules" = ["group/pill-workspaces" "group/pill-media-time"];
          };

          "group/pill-center" = {
            "orientation" = "inherit";
            "modules" = [
              "wlr/taskbar"
            ];
          };

          "group/pill-right" = {
            orientation = "inherit";
            modules = ["custom/typing" "custom/weather" "backlight" "pulseaudio" "bluetooth" "network" "battery"];
          };

          "wlr/taskbar" = {
            "all-outputs" = true;
            "active-first" = false;
            "markup" = true;
            "format" = "{icon}";
            "rotate" = 0;
            "spacing" = 20;
            "tooltip-format" = "{title} | {app_id}";
            "on-click" = "activate";
            "on-click-right" = "fullscreen";
            "on-click-middle" = "close";
            "class" = "no-margin-padding";
          };

          "custom/launcher" = {
            format = "󱄅";
            on-click = "${pkgs.rofi}/bin/rofi -show drun";
          };
          "hyprland/workspaces" = {
            format = "{icon}";
            format-icons = {
              "1" = "";
              "2" = "󰈹";
              "3" = "󰠮";
              "4" = "";
              "5" = "";
              "6" = "";
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
          "custom/typing" = {
            exec = "${typing}/bin/typing";
            format = "  {}";
            interval = 3;
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
            format-icons = ["" " " " "];
            on-click = "${pkgs.pavucontrol}/bin/pavucontrol";
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
            format-ethernet = ""; # Hide module
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
            format = "{:%d.%m.%Y - %H:%M}";
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
          min-height: 0;
          font-size: 10px;
        }

        window#waybar {
          background: rgba(0,0,0,0.2);
        }

        #pill-media-time,
        #pill-workspaces,
        #pill-right,
        #pill-center {
          padding: 0em 1em;
          border-radius: 20pt 20pt 20pt 20pt;
          background: rgba(30,30,46,0.7);
          color: #FFFFFF;
        }

        #custom-launcher {
          background: #b4befe;
          color: #${config.scheme.base02};
          border-radius: 20pt 20pt 20pt 20pt;
          padding-left: 1.2em;
          padding-right: 1.2em;
          margin-right: 1em;
          margin-bottom: 0.3em;
          margin-top: 0.3em;
        }

        #pill-workspaces {
          margin: 0 1em;
        }

        #workspaces button {
            box-shadow: none;
            text-shadow: none;
            padding: 0em;
            margin-top: 0.3em;
            margin-bottom: 0.3em;
            margin-left: 0em;
            padding-left: 0.3em;
            padding-right: 0.3em;
            margin-right: 0em;
            animation: ws_normal 20s ease-in-out 1;
            border-radius: 20pt 20pt 20pt 20pt;
        }

        #workspaces button.active {
            background: #b4befe;
            color: rgba(30,30,46,0.7);
            margin-left: 0.3em;
            padding-left: 1.2em;
            padding-right: 1.2em;
            margin-right: 0.3em;
            animation: ws_active 20s ease-in-out 1;
            transition: all 0.4s cubic-bezier(.55, -0.68, .48, 1.682);
            border-radius: 20pt 20pt 20pt 20pt;
        }

        #workspaces button:hover {
            background: #b4befe;
            color: rgba(30,30,46,0.7);
            animation: ws_hover 20s ease-in-out 1;
            transition: all 0.3s cubic-bezier(.55, -0.68, .48, 1.682);
            border-radius: 20pt 20pt 20pt 20pt;
        }

        #taskbar button {
            box-shadow: none;
            text-shadow: none;
            padding: 0em;
            margin-top: 0.3em;
            margin-bottom: 0.3em;
            margin-left: 0em;
            padding-left: 0.3em;
            padding-right: 0.3em;
            margin-right: 0em;
            animation: tb_normal 20s ease-in-out 1;
        }

        #taskbar button.active {
            background: #b4befe;
            margin-left: 0.3em;
            padding-left: 1.2em;
            padding-right: 1.2em;
            margin-right: 0.3em;
            animation: tb_active 20s ease-in-out 1;
            transition: all 0.4s cubic-bezier(.55, -0.68, .48, 1.682);
            border-radius: 20pt 20pt 20pt 20pt;
        }

        #taskbar button:hover {
            background: #b4befe;
            animation: tb_hover 20s ease-in-out 1;
            transition: all 0.3s cubic-bezier(.55, -0.68, .48, 1.682);
            border-radius: 20pt 20pt 20pt 20pt;
        }

        #workspaces button.urgent {
        }

        #mpris{
          margin-left: 2em;
        }

        #custom-typing {
          margin: 0 1em;
        }

        #custom-weather {
          margin: 0 1em;
        }

        #backlight {
          margin: 0 1em;
        }

        #pulseaudio {
          margin: 0 1em;
        }

        #pulseaudio.muted {
        }



        #bluetooth {
          margin: 0 1em;
        }

        #bluetooth.on {
        }

        #bluetooth.connected {
        }

        #network {
          margin: 0 1em;
        }

        #network.disconnected {
        }

        #battery {
          margin: 0 1em;
        }

        #battery.charging {
        }

        @keyframes blink {
          to {
            color: #ffffff;
          }
        }

        #battery.warning:not(.charging) {
        }

        #battery.critical:not(.charging) {
          animation-name: blink;
          animation-duration: 0.5s;
          animation-timing-function: linear;
          animation-iteration-count: infinite;
          animation-direction: alternate;
        }


        #clock {
          margin: 0 1em;
        }
      '';
    };
  };
}
