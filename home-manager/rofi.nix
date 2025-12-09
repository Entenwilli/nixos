{
  lib,
  pkgs,
  config,
  inputs,
  ...
}: {
  options = {
    rofi.enable = lib.mkEnableOption "Enable rofi";
  };

  config = lib.mkIf config.rofi.enable {
    programs.wlogout = {
      enable = true;
      layout = [
        {
          label = "lock";
          action = "${pkgs.hyprlock}/bin/hyprlock";
          text = "Lock";
          keybind = "l";
        }
        {
          label = "shutdown";
          action = "hyprshutdown --dry-run --verbose --post-cmd 'systemctl poweroff'";
          text = "Shutdown";
          keybind = "s";
        }
        {
          label = "reboot";
          action = "hyprshutdown --dry-run --verbose --post-cmd 'systemctl reboot'";
          text = "Reboot";
          keybind = "r";
        }
      ];
      style = ''
        * {
          background-image: none;
          font-size: 20px;
        }

        window {
            background-color: transparent;
        }

        button {
            color: #cba6f7;
            background-color: #313244;
            outline-style: none;
            border: none;
            border-width: 0px;
            background-repeat: no-repeat;
            background-position: center;
            background-size: 20%;
            border-radius: 0px;
            box-shadow: none;
            text-shadow: none;
            animation: gradient_f 20s ease-in infinite;
        }

        button:focus {
            background-color: #cba6f7;
            color: #cdd6f4;
            background-size: 30%;
        }

        button:hover {
            background-color: #cba6f7;
            color: #cdd6f4;
            background-size: 40%;
            border-radius: 20px;
            animation: gradient_f 20s ease-in infinite;
            transition: all 0.3s cubic-bezier(.55,0.0,.28,1.682);
        }

        button:hover#lock {
            border-radius: 20px;
            margin : 20px 0px 20px 5px;
        }

        button:hover#logout {
            border-radius: 20px;
            margin : 20px 0px 20px 5px;
        }

        button:hover#suspend {
            border-radius: 20px;
            margin : 20px 0px 20px 5px;
        }

        button:hover#shutdown {
            border-radius: 20px;
            margin : 20px 0px 20px 5px;
        }

        button:hover#hibernate {
            border-radius: 20px;
            margin : 20px 0px 20px 5px;
        }

        button:hover#reboot {
            border-radius: 20px;
            margin : 20px 0px 20px 5px;
        }

        #logout,
        #suspend,
        #shutdown,
        #hibernate,
        #reboot,
        #lock {
            margin : 5px 0px 5px 0px;
        }

        #logout {
          background-image: image(url("${./wlogout/logout.png}"));
        }

        #suspend {
          background-image: image(url("${./wlogout/suspend.png}"));
        }

        #shutdown {
          background-image: image(url("${./wlogout/shutdown.png}"));
        }

        #hibernate {
          background-image: image(url("${./wlogout/hibernate.png}"));
        }

        #reboot {
          background-image: image(url("${./wlogout/reboot.png}"));
            border-radius: 0px 20px 20px 0px;
            margin : 5px 5px 5px 0px;
        }

        #lock {
          background-image: image(url("${./wlogout/lock.png}"));
            border-radius: 20px 0px 0px 20px;
            margin : 5px 0px 5px 5px;
        }
      '';
    };

    home.sessionVariables = {
      DMENU_BLUETOOTH_LAUNCHER = "rofi";
    };

    home.packages = with pkgs; [
      bemoji
      wtype
      inputs.hyprshutdown.packages.${stdenv.hostPlatform.system}.hyprshutdown
    ];

    programs.rofi = {
      enable = true;
      package = pkgs.rofi;
      font = "FiraCode Nerd Font 15";
      terminal = "${pkgs.kitty}/bin/kitty";
      plugins = with pkgs; [
        rofi-calc
      ];
      extraConfig = {
        modi = "window,run,drun";
        show-icons = true;
        display-drun = " ";
        display-run = " ";
        display-filebrowser = " ";
        display-window = " ";
        drun-display-format = "{name}";
        window-format = "{w} · {c} · {t}";
      };

      theme = let
        inherit (config.lib.formats.rasi) mkLiteral;
        background = mkLiteral "#${config.scheme.base00}B3";
        background-alt = mkLiteral "#${config.scheme.base03}B3";
        foreground = mkLiteral "#${config.scheme.base06}FF";
        selected = mkLiteral "#${config.scheme.base02}B3";
        active = mkLiteral "#${config.scheme.base03}FF";
        urgent = mkLiteral "#${config.scheme.base0F}FF";
      in {
        "*" = {
          border-color = selected;
          handle-color = selected;
          background-color = background;
          foreground-color = foreground;
          alternate-background = background-alt;
          normal-background = mkLiteral "transparent";
          normal-foreground = foreground;
          urgent-background = urgent;
          urgent-foreground = background;
          active-background = active;
          active-foreground = background;

          selected-normal-background = selected;
          selected-normal-foreground = foreground;
          selected-urgent-background = active;
          selected-urgent-foreground = foreground;
          selected-active-background = urgent;
          selected-active-foreground = foreground;

          alternate-normal-background = mkLiteral "transparent";
          alternate-normal-foreground = foreground;
          alternate-urgent-background = urgent;
          alternate-urgent-foreground = background;
          alternate-active-background = active;
          alternate-active-foreground = background;
        };

        window = {
          transparency = "real";
          location = mkLiteral "center";
          anchor = mkLiteral "center";
          fullscreen = mkLiteral "false";
          width = mkLiteral "600px";
          x-offset = mkLiteral "0px";
          y-offset = mkLiteral "0px";

          enabled = true;
          margin = mkLiteral "0px";
          padding = mkLiteral "0px";
          border = mkLiteral "0px solid";
          border-radius = mkLiteral "10px";
          border-color = mkLiteral "@border-color";
          cursor = "default";
          background-color = mkLiteral "@background-color";
        };

        mainbox = {
          enabled = true;
          spacing = mkLiteral "10px";
          margin = mkLiteral "0px";
          padding = mkLiteral "30px";
          border = mkLiteral "0px solid";
          border-radius = mkLiteral "0px 0px 0px 0px";
          border-color = mkLiteral "@border-color";
          background-color = mkLiteral "transparent";
          children = map mkLiteral ["inputbar" "message" "listview"];
        };

        inputbar = {
          enabled = true;
          spacing = mkLiteral "10px";
          margin = mkLiteral "0px";
          padding = mkLiteral "0px";
          border = mkLiteral "0px solid";
          border-radius = mkLiteral "0px";
          border-color = mkLiteral "@border-color";
          background-color = mkLiteral "transparent";
          text-color = mkLiteral "@foreground-color";
          children = map mkLiteral ["textbox-prompt-colon" "entry" "mode-switcher"];
        };

        prompt = {
          enabled = true;
          background-color = mkLiteral "inherit";
          text-color = mkLiteral "inherit";
        };

        textbox-prompt-colon = {
          enabled = true;
          padding = mkLiteral "5px";
          expand = false;
          str = "";
          background-color = mkLiteral "inherit";
          text-color = mkLiteral "inherit";
        };

        entry = {
          enabled = true;
          padding = mkLiteral "5px 0px";
          background-color = mkLiteral "inherit";
          text-color = mkLiteral "inherit";
          cursor = mkLiteral "text";
          placeholder = "Search...";
          placeholder-color = mkLiteral "inherit";
        };

        num-filtered-rows = {
          enabled = true;
          expand = false;
          background-color = mkLiteral "inherit";
          text-color = mkLiteral "inherit";
        };

        textbox-num-sep = {
          enabled = true;
          expand = false;
          str = "/";
          background-color = mkLiteral "inherit";
          text-color = mkLiteral "inherit";
        };

        num-rows = {
          enabled = true;
          expand = false;
          background-color = mkLiteral "inherit";
          text-color = mkLiteral "inherit";
        };

        case-indicator = {
          enabled = true;
          background-color = mkLiteral "inherit";
          text-color = mkLiteral "inherit";
        };

        listview = {
          enabled = true;
          columns = 1;
          lines = 8;
          cycle = true;
          dynamic = true;
          scrollbar = true;
          layout = mkLiteral "vertical";
          reverse = false;
          fixed-height = true;
          fixed-columns = true;

          spacing = mkLiteral "5px";
          margin = mkLiteral "0px";
          padding = mkLiteral "0px";
          border = mkLiteral "0px solid";
          border-radius = mkLiteral "0px";
          border-color = mkLiteral "@border-color";
          background-color = mkLiteral "transparent";
          text-color = mkLiteral "@foreground-color";
          cursor = "default";
        };

        scrollbar = {
          handle-width = mkLiteral "5px";
          handle-color = mkLiteral "@handle-color";
          border-radius = mkLiteral "10px";
          background-color = mkLiteral "@alternate-background";
        };

        "element" = {
          enabled = true;
          spacing = mkLiteral "10px";
          margin = mkLiteral "0px";
          padding = mkLiteral "5px 10px";
          border = mkLiteral "0px solid";
          border-radius = mkLiteral "10px";
          border-color = mkLiteral "@border-color";
          background-color = mkLiteral "transparent";
          text-color = mkLiteral "@foreground-color";
          cursor = mkLiteral "pointer";
        };

        "element normal.normal" = {
          background-color = mkLiteral "@normal-background";
          text-color = mkLiteral "@normal-foreground";
        };

        "element normal.urgent" = {
          background-color = mkLiteral "@urgent-background";
          text-color = mkLiteral "@urgent-foreground";
        };

        "element normal.active" = {
          background-color = mkLiteral "@active-background";
          text-color = mkLiteral "@active-foreground";
        };

        "element selected.normal" = {
          background-color = mkLiteral "@selected-normal-background";
          text-color = mkLiteral "@selected-normal-foreground";
        };

        "element selected.urgent" = {
          background-color = mkLiteral "@selected-urgent-background";
          text-color = mkLiteral "@selected-urgent-foreground";
        };

        "element selected.active" = {
          background-color = mkLiteral "@selected-active-background";
          text-color = mkLiteral "@selected-active-foreground";
        };

        "element alternate.normal" = {
          background-color = mkLiteral "@alternate-normal-background";
          text-color = mkLiteral "@alternate-normal-foreground";
        };

        "element alternate.urgent" = {
          background-color = mkLiteral "@alternate-urgent-background";
          text-color = mkLiteral "@alternate-urgent-foreground";
        };

        "element alternate.active" = {
          background-color = mkLiteral "@alternate-active-background";
          text-color = mkLiteral "@alternate-active-foreground";
        };

        element-icon = {
          background-color = mkLiteral "transparent";
          text-color = mkLiteral "inherit";
          size = mkLiteral "24px";
          cursor = mkLiteral "inherit";
        };

        element-text = {
          background-color = mkLiteral "transparent";
          text-color = mkLiteral "inherit";
          highlight = mkLiteral "inherit";
          cursor = mkLiteral "inherit";
          vertical-align = mkLiteral "0.5";
          horizontal-align = mkLiteral "0.0";
        };

        mode-switcher = {
          enabled = true;
          spacing = mkLiteral "10px";
          margin = mkLiteral "0px";
          padding = mkLiteral "0px";
          border = mkLiteral "0px solid";
          border-radius = mkLiteral "0px";
          border-color = mkLiteral "@border-color";
          background-color = mkLiteral "transparent";
          text-color = mkLiteral "@foreground-color";
        };

        "button" = {
          padding = mkLiteral "5px 10px";
          border = mkLiteral "0px solid";
          border-radius = mkLiteral "10px";
          border-color = mkLiteral "@border-color";
          background-color = mkLiteral "@alternate-background";
          text-color = mkLiteral "inherit";
          cursor = mkLiteral "pointer";
        };

        "button selected" = {
          background-color = mkLiteral "@selected-normal-background";
          text-color = mkLiteral "@selected-normal-foreground";
        };

        message = {
          enabled = true;
          margin = mkLiteral "0px";
          padding = mkLiteral "0px";
          border = mkLiteral "0px solid";
          border-radius = mkLiteral "0px 0px 0px 0px";
          border-color = mkLiteral "@border-color";
          background-color = mkLiteral "transparent";
          text-color = mkLiteral "@foreground-color";
        };

        textbox = {
          padding = mkLiteral "8px 10px";
          border = mkLiteral "0px solid";
          border-radius = mkLiteral "10px";
          border-color = mkLiteral "@border-color";
          background-color = mkLiteral "@alternate-background";
          text-color = mkLiteral "@foreground-color";
          vertical-align = mkLiteral "0.5";
          horizontal-align = mkLiteral "0.0";
          highlight = mkLiteral "none";
          placeholder-color = mkLiteral "@foreground-color";
          blink = true;
          markup = true;
        };

        error-message = {
          padding = mkLiteral "10px";
          border = mkLiteral "2px solid";
          border-radius = mkLiteral "10px";
          border-color = mkLiteral "@border-color";
          background-color = mkLiteral "@background-color";
          text-color = mkLiteral "@foreground-color";
        };
      };
    };
  };
}
