{
  inputs,
  lib,
  pkgs,
  config,
  ...
}: let
  volume = pkgs.writeShellApplication {
    name = "volume";
    text = ''
      ctl=${pkgs.pamixer}/bin/pamixer
      lockfile=~/.config/volume-lockfile
      iconDir="${pkgs.papirus-icon-theme}/Papirus-Dark/48x48/status"

      while [ -f "$lockfile" ]; do
          sleep 0.1;
      done
      touch "$lockfile"


      getIcon() {
          vol=$("$ctl" --get-volume)
          mute=$("$ctl" --get-mute)
          #echo $vol

          if [ "$mute" == "true" ]; then
              echo "$iconDir/notification-audio-volume-muted.svg"
          else
              if [ "$vol" -lt 33 ]; then
                  echo "$iconDir/notification-audio-volume-low.svg"
              elif [ "$vol" -lt 66 ]; then
                  echo "$iconDir/notification-audio-volume-medium.svg"
              else
                  echo "$iconDir/notification-audio-volume-high.svg"
              fi
          fi
      }



      val="5"
      orig=$("$ctl" --get-volume)
      subinc=5


      if [ "$1" == "mute" ]; then
          opt="--toggle-mute"
          "$ctl" "$opt"
      else
          if [ "$1" == "inc" ]; then
              opt="--increase"
              if [ "$2" != "" ]; then val="$2"; fi

          elif [ "$1" == "dec" ]; then
              opt="--decrease"
              if [ "$2" != "" ]; then val="$2"; fi

          fi

          "$ctl" "$opt" "$val" &

          # Fake the animated volume
          for i in $(seq "$val"); do
              operation="+"
              inverse="-"
              if [ "$1" == "dec" ]; then
                  operation="-"
                  inverse="+"
              fi

              # shellcheck disable=all
              current=$(( ($orig "$operation" $i) "$inverse" 1 ))
              if [ "$current" -lt 0 ]; then
                  current=0
                  rm "$lockfile"
                  exit 1
              fi

              mute=$("$ctl" --get-mute)
              ntext="Volume at $current%"
              if [ "$mute" == "true" ]; then
                  ntext="Volume muted"
              fi

              dunstify -i "$(getIcon)" -u normal -h string:x-dunst-stack-tag:volume -a "Speaker" "$ntext" -h "int:value:''${current}"
          done

      fi

      current=$("$ctl" --get-volume)
      mute=$("$ctl" --get-mute)
      ntext="Volume at $current%"

      if [ "$mute" == "true" ]; then
          ntext="Volume muted"
      fi

      dunstify -i "$(getIcon)" -u normal -h string:x-dunst-stack-tag:volume -a "Speaker" "$ntext" -h "int:value:''${current}"


      rm "$lockfile"
    '';
  };
  location = pkgs.writeShellApplication {
    name = "location";

    text = ''
      cache_file="$HOME/.cache/ip_cache.txt"

      if [ ! -f "$cache_file" ]; then
      	mkdir -p "$(dirname "$cache_file")" 
      	touch "$cache_file"
      fi

      last_modified=$(stat -c %Y "$cache_file")
      current_date=$(date +%s)
      time_diff=$((current_date - last_modified))
      expiry_time=86400
      cached_data=$(<"$cache_file")

      if [ $time_diff -lt $expiry_time ] && [ -n "$cached_data" ]; then
      	echo "$cached_data"
      	exit
      fi

      response=$(curl -s ipinfo.io 2>/dev/null | jq -r '.country + ", " + .city' 2>/dev/null)
      city=$response
      echo "$city" >"$cache_file"    '';
  };
  weather = pkgs.writeShellApplication {
    name = "weather";
    text = ''
      cache_file="$HOME/.cache/wttr_cache.txt"

      if [ ! -f "$cache_file" ]; then
      	mkdir -p "$(dirname "$cache_file")" # Create .cache directory if it doesn't exist
      	touch "$cache_file"
      fi

      last_modified=$(stat -c %Y "$cache_file")
      current_date=$(date +%s)
      time_diff=$((current_date - last_modified))
      expiry_time=86400
      cached_data=$(<"$cache_file")

      if [ $time_diff -lt $expiry_time ] && [ -n "$cached_data" ]; then
      	echo "$cached_data"
      	exit
      fi

      response=$(curl -s wttr.in?format=%c+%C+%t 2>/dev/null)
      city=$response
      echo "$city" >"$cache_file"
    '';
  };
in {
  options.hyprland = {
    enable = lib.mkEnableOption "Enable hyprland";
    keyboardLayout = lib.mkOption {
      default = "de";
      type = lib.types.str;
    };
    hyprpaper.enable = lib.mkEnableOption "Enable hyprpaper";
    additional_config = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = ''
        Additional config for hypr.conf
      '';
    };

    monitors = lib.mkOption {
      default = [];
      description = ''
        Monitors connected to hyprland
      '';
      type = lib.types.listOf (lib.types.submodule {
        options = {
          name = lib.mkOption {
            type = lib.types.str;
            description = ''
              Name of the monitor
            '';
          };
          mode = lib.mkOption {
            type = lib.types.str;
            default = "auto";
            description = ''
              Hyprland resolution for monitor
            '';
          };
          position = lib.mkOption {
            type = lib.types.str;
            default = "0x0";
            description = ''
              Hyprland position of the display
            '';
          };
          scale = lib.mkOption {
            type = lib.types.float;
            default = 1.0;
            description = ''
              Scale of the monitor
            '';
          };
          mirror = lib.mkOption {
            type = lib.types.str;
            default = "";
            description = ''
              Mirrors the display to the given monitor
            '';
          };
          hdr = lib.mkEnableOption "Enable hdr";
          sdr_min_luminance = lib.mkOption {
            type = lib.types.float;
            description = ''
              SDR minimum lumninace used for SDR → HDR mapping. Set to 0.005 for true black matching HDR black
            '';
          };
          sdr_max_luminance = lib.mkOption {
            type = lib.types.int;
            description = ''
              SDR maximum luminance. Can be used to adjust overall SDR → HDR brightness. 80 - 400 is a reasonable range. The desired value is likely between 200 and 250
            '';
          };
          wallpaper = lib.mkOption {
            type = lib.types.str;
            description = ''
              Path to the monitor wallpaper
            '';
          };
        };
      });
    };
  };

  config = lib.mkIf config.hyprland.enable {
    home.packages = with pkgs; [
      clipse
      catppuccin-cursors.mochaMauve
    ];
    wayland.windowManager.hyprland = {
      enable = true;

      package = null;
      portalPackage = null;

      systemd.enable = true;
      systemd.enableXdgAutostart = true;
      systemd.variables = ["--all"];

      importantPrefixes = ["$" "name" "bezier" "output"];
      configType = "lua";
      settings = {
        mainMod = {
          _var = "SUPER";
        };
        mainModShift = {
          _var = "SUPER + SHIFT";
        };

        monitor = builtins.map ({
          name,
          mode,
          position,
          mirror,
          hdr,
          sdr_min_luminance,
          sdr_max_luminance,
          ...
        }:
          if (mirror != "")
          then {
            output = name;
            mode = "prefered";
            position = "auto";
            mirror = mirror;
          }
          else {
            output = name;
            mode = mode;
            position = position;
            #supports_wide_color = hdr;
            #supports_hdr = hdr;
            #sdr_min_luminance = sdr_min_luminance;
            #sdr_max_luminance = sdr_max_luminance;
          })
        config.hyprland.monitors;

        config = {
          general = {
            gaps_in = 5;
            gaps_out = 10;
            border_size = 1;
            "col.active_border" = "rgba(0DB7D455)";
            "col.inactive_border" = "rgba(31313600)";
            layout = "dwindle";
            allow_tearing = false;
          };

          input = {
            kb_layout = lib.strings.concatStrings [
              config.hyprland.keyboardLayout
              (
                if config.hyprland.keyboardLayout != "us"
                then ",us"
                else ""
              )
            ];
            kb_variant = lib.mkIf (config.hyprland.keyboardLayout == "us") "altgr-intl";
            follow_mouse = 1;
            mouse_refocus = false;
            touchpad = {
              natural_scroll = false;
            };
            sensitivity = "-0.3";
          };

          decoration = {
            rounding_power = 2.4;
            rounding = 18;

            blur = {
              enabled = true;
              xray = true;
              new_optimizations = true;
              size = 10;
              passes = 3;
            };

            shadow = {
              enabled = true;
              range = 50;
              offset = "0 4";
              render_power = 10;
              color = "rgba(00000027)";
            };
          };

          dwindle = {
            preserve_split = true;
          };

          misc = {
            disable_hyprland_logo = 1;
            disable_splash_rendering = 1;
          };

          debug = {
            disable_logs = false;
          };
        };

        #animations = {
        #  enabled = "yes";
        #  bezier = "myBezier, 0.05, 0.9, 0.1, 1.05";
        #  animation = [
        #    "windows, 1, 7, myBezier"
        #    "windowsOut, 1, 7, default, popin 80%"
        #    "border, 1, 10, default"
        #    "borderangle, 1, 8, default"
        #    "fade, 1, 7, default"
        #    "workspaces, 1, 6, default"
        #  ];
        #};

        window_rule = [
          {
            no_initial_focus = true;
            match.class = "(jetbrains-)(.*)";
            match.float = true;
          }
          {
            border_size = 0;
            rounding = 0;
            match.class = "^(clipstudiopaint.exe)$";
          }
          {
            opacity = "0.90 0.90";
            match.class = "^(zen-twilight)$";
          }
          {
            opacity = "1 override 1 override";
            match.class = "^(zen-twilight)$";
            match.title = "(.*)(- Youtube)(.*)";
          }
          {
            opacity = "1 override 1 override";
            match.class = "^(zen-twilight)$";
            match.title = "(.*)(-Twitch)(.*)";
          }
          {
            opacity = "0.90 0.85";
            match.class = "^(kitty)$";
          }
          {
            opacity = "0.90 0.85";
            match.class = "^(anki)$";
          }
          {
            opacity = "0.90 0.85";
            match.class = "^(discord)$";
          }
          {
            opacity = "0.90 0.85";
            match.class = "^(spotify)$";
          }
          {
            opacity = "0.90 0.85";
            match.class = "^(VenCord)$";
          }
          {
            opacity = "0.90 0.85";
            match.title = "^(Rofi.*)$";
          }
          {
            opacity = "0.90 0.85";
            match.class = "^(neovide)$";
          }
          {
            float = true;
            center = true;
            match.class = "^org\\.keepassxc\\.KeePassXC$, title:^Unlock Database - KeePassXC$";
          }
          {
            float = true;
            center = true;
            match.class = "^org\\.keepassxc\\.KeePassXC$, title:^KeePassXC - Browser Access Request$";
          }
          {
            float = true;
            center = true;
            match.class = "^org\\.keepassxc\\.KeePassXC$, title:^KeePassXC -  Access Request$";
          }
          {
            float = true;
            center = true;
            match.class = "^org\\.keepassxc\\.KeePassXC$, title:^KeePassXC - Passkey credentials$";
          }
          {
            float = true;
            size = "880 500";
            match.class = "^org\\.keepassxc\\.KeePassXC$, title:^.*\\[Locked\\] - KeePassXC";
          }
          {
            float = true;
            match.class = "^XIVLauncher\.Core$";
          }
          {
            opacity = "0.90 0.85";
            match.class = "^(obsidian)$";
          }
          {
            float = true;
            no_anim = true;
            no_shadow = true;
            border_size = 0;
            match.class = "^(ueberzug.*)$";
          }
          {
            size = "150 150";
            match.class = "cover";
          }
        ];

        layer_rule = [
          {
            blur = true;
            match.namespace = "logout_dialog";
          }
          {
            blur = true;
            match.namespace = "rofi";
          }
        ];

        bind =
          [
            {
              _args = [
                (lib.generators.mkLuaInline "mainMod ..\"+ Return\"")
                (lib.generators.mkLuaInline "hl.dsp.exec_cmd(\"kitty\")")
              ];
            }
            {
              _args = [
                (lib.generators.mkLuaInline "mainModShift ..\"+ Q\"")
                (lib.generators.mkLuaInline "hl.dsp.window.close()")
              ];
            }
            {
              _args = [
                (lib.generators.mkLuaInline "mainModShift ..\"+ E\"")
                (lib.generators.mkLuaInline "hl.dsp.exec_cmd(\"wlogout\")")
              ];
            }
            {
              _args = [
                (lib.generators.mkLuaInline "mainMod ..\"+ V\"")
                (lib.generators.mkLuaInline "hl.dsp.window.float({ action = \"toggle\"})")
              ];
            }
            {
              _args = [
                (lib.generators.mkLuaInline "mainMod ..\"+ D\"")
                (lib.generators.mkLuaInline "hl.dsp.exec_cmd(\"${pkgs.rofi}/bin/rofi -modi drun,run -show drun\")")
              ];
            }
            {
              _args = [
                (lib.generators.mkLuaInline "mainMod ..\"+ C\"")
                (lib.generators.mkLuaInline "hl.dsp.exec_cmd(\"rofi -show calc -modi calc -no-show-match -no-sort\")")
              ];
            }
            {
              _args = [
                (lib.generators.mkLuaInline "mainMod..\"+ Period\"")
                (lib.generators.mkLuaInline "hl.dsp.exec_cmd(\"${pkgs.bemoji}/bin/bemoji -t\")")
              ];
            }
            {
              _args = [
                (lib.generators.mkLuaInline "mainMod ..\"+ P\"")
                (lib.generators.mkLuaInline "hl.dsp.window.pseudo()")
              ];
            }
            {
              _args = [
                (lib.generators.mkLuaInline "mainMod ..\"+ F\"")
                (lib.generators.mkLuaInline "hl.dsp.window.fullscreen()")
              ];
            }
            {
              _args = [
                (lib.generators.mkLuaInline "mainMod ..\"+ S\"")
                (lib.generators.mkLuaInline "hl.dsp.workspace.toggle_special(\"magic\")")
              ];
            }
            {
              _args = [
                (lib.generators.mkLuaInline "mainMod..\"+ SHIFT + S\"")
                (lib.generators.mkLuaInline "hl.dsp.window.move({workspace = \"special:magic\"})")
              ];
            }
            {
              _args = [
                (lib.generators.mkLuaInline "mainMod..\"+ mouse_down\"")
                (lib.generators.mkLuaInline "hl.dsp.focus({workspace = \"e+1\"})")
              ];
            }
            {
              _args = [
                (lib.generators.mkLuaInline "mainMod..\"+ mouse_up\"")
                (lib.generators.mkLuaInline "hl.dsp.focus({workspace = \"e-1\"})")
              ];
            }
            {
              _args = [
                "XF86AudioRaiseVolume"
                (lib.generators.mkLuaInline "hl.dsp.exec_cmd(\"${volume}/bin/volume inc 3\")")
              ];
            }
            {
              _args = [
                "XF86AudioLowerVolume"
                (lib.generators.mkLuaInline "hl.dsp.exec_cmd(\"${volume}/bin/volume dec 3\")")
              ];
            }
            {
              _args = [
                "XF86AudioMute"
                (lib.generators.mkLuaInline "hl.dsp.exec_cmd(\"${volume}/bin/volume mute\")")
              ];
            }
            {
              _args = [
                "XF86AudioPlay"
                (lib.generators.mkLuaInline "hl.dsp.exec_cmd(\"${pkgs.playerctl}/bin/playerctl play-pause\")")
              ];
            }
            {
              _args = [
                "XF86AudioPause"
                (lib.generators.mkLuaInline "hl.dsp.exec_cmd(\"${pkgs.playerctl}/bin/playerctl play-pause\")")
              ];
            }
            {
              _args = [
                "XF86MonBrightnessUp"
                #TODO: Convert to nix
                (lib.generators.mkLuaInline "hl.dsp.exec_cmd(\"/home/felix/.config/scripts/backlight.sh inc 5\")")
              ];
            }
            {
              _args = [
                "XF86MonBrightnessDown"
                #TODO: Convert to nix
                (lib.generators.mkLuaInline "hl.dsp.exec_cmd(\"/home/felix/.config/scripts/backlight.sh dec 5\")")
              ];
            }
            {
              _args = [
                (lib.generators.mkLuaInline "mainMod ..\" + mouse:272\"")
                (lib.generators.mkLuaInline "hl.dsp.window.drag()")
                {mouse = true;}
              ];
            }
            {
              _args = [
                (lib.generators.mkLuaInline "mainMod ..\" + mouse:273\"")
                (lib.generators.mkLuaInline "hl.dsp.window.resize()")
                {mouse = true;}
              ];
            }
          ]
          ++ builtins.map ({
            key,
            workspace,
          }: {
            _args = [
              (lib.generators.mkLuaInline "mainMod .. \" + ${builtins.toString key}\"")
              (lib.generators.mkLuaInline "hl.dsp.focus({ workspace = ${builtins.toString workspace}})")
            ];
          }) [
            {
              key = 1;
              workspace = 1;
            }
            {
              key = 2;
              workspace = 2;
            }
            {
              key = 3;
              workspace = 3;
            }
            {
              key = 4;
              workspace = 4;
            }
            {
              key = 5;
              workspace = 5;
            }
            {
              key = 6;
              workspace = 6;
            }
            {
              key = 7;
              workspace = 7;
            }
            {
              key = 8;
              workspace = 8;
            }
            {
              key = 9;
              workspace = 9;
            }
            {
              key = 0;
              workspace = 10;
            }
          ]
          ++ builtins.map ({
            key,
            workspace,
          }: {
            _args = [
              (lib.generators.mkLuaInline "mainMod .. \" + SHIFT + ${builtins.toString key}\"")
              (lib.generators.mkLuaInline "hl.dsp.window.move({ workspace = ${builtins.toString workspace}})")
            ];
          }) [
            {
              key = 1;
              workspace = 1;
            }
            {
              key = 2;
              workspace = 2;
            }
            {
              key = 3;
              workspace = 3;
            }
            {
              key = 4;
              workspace = 4;
            }
            {
              key = 5;
              workspace = 5;
            }
            {
              key = 6;
              workspace = 6;
            }
            {
              key = 7;
              workspace = 7;
            }
            {
              key = 8;
              workspace = 8;
            }
            {
              key = 9;
              workspace = 9;
            }
            {
              key = 0;
              workspace = 10;
            }
          ];
        on = {
          _args = [
            "hyprland.start"
            (lib.generators.mkLuaInline ("function()\n"
              + lib.strings.concatMapStrings (command: "hl.exec_cmd(\"${command}\")\n") [
                "hyprlock"
                "hypridle"
                "systemctl --user start hyprpolkitagent"
                "keepassxc"
                "${pkgs.clipse}/bin/clipse -listen"
                "fcitx5 -d"
                "systemctl --user import-environment QT_QPA_PLATFORMTHEME DBUS_SESSION_ADDRESS"
              ]
              + "end"))
          ];
        };
        env = [
          {
            _args = [
              "QT_QPA_PLATFORMTHEME"
              "qt6ct"
            ];
          }
          {
            _args = [
              "XDG_SESSION_TYPE"
              "wayland"
            ];
          }
        ];
        device = [
          {
            name = "keychron-keychron-q1";
            kb_layout = "us";
            kb_variant = "altgr-intl";
            resolve_binds_by_sym = true;
          }
          {
            name = "keychron-keychron-q1-keyboard";
            kb_layout = "us";
            kb_variant = "altgr-intl";
            resolve_binds_by_sym = true;
          }
        ];
      };
    };

    services.hyprpaper = {
      enable = config.hyprland.hyprpaper.enable;
      package = inputs.hyprpaper.packages.${pkgs.stdenv.hostPlatform.system}.hyprpaper;
      settings = {
        splash = false;

        preload = builtins.map ({wallpaper, ...}: "${wallpaper}") config.hyprland.monitors;

        wallpaper = builtins.map ({
          name,
          wallpaper,
          ...
        }: "${name},${wallpaper}")
        config.hyprland.monitors;
      };
    };

    home.file.".config/hypr/hypridle.conf".text = ''
       general {
        lock_cmd = pidof hyprlock || hyprlock
        before_sleep_cmd = loginctl lock-session
        after_sleep_cmd = hyprctl dispatch dpms on
      }

      listener {
          timeout = 150
          on-timeout = [ "$(cat /sys/class/power_supply/AC/online)" = "0" ] && brightnessctl -s set 10
          on-resume = [ "$(cat /sys/class/power_supply/AC/online)" = "0" ] && brightnessctl -r
      }

      listener {
          timeout = 150
          on-timeout = [ "$(cat /sys/class/power_supply/AC/online)" = "0" ] && brightnessctl -sd rgb:kbd_backlight set 0
      }

      listener {
          timeout = 300
          on-timeout = [ "$(cat /sys/class/power_supply/AC/online)" = "0" ] && hyprctl dispatch dpms off
          on-resume = [ "$(cat /sys/class/power_supply/AC/online)" = "0" ] && hyprctl dispatch dpms on
      }
    '';

    home.file.".config/hypr/xdph.conf".text = ''
      screencopy {
        max_fps = 144
        allow_token_by_default = true
        custom_picker_binary = ${pkgs.hyprland-preview-share-picker}/bin/hyprland-preview-share-picker
      }
    '';

    home.file.".config/hyprland-preview-share-picker/config.yaml".text = ''
      # default page selected when the picker is opened
      default_page: outputs

      window:
        height: 500
        width: 1000

      image:
        resize_size: 200
        widget_size: 150

      windows:
        # minimum amount of image cards per row on the windows page
        min_per_row: 3
        # maximum amount of image cards per row on the windows page
        max_per_row: 999
        # number of clicks needed to select a window
        clicks: 2
        # spacing in pixels between the window cards
        spacing: 12

      outputs:
        # number of clicks needed to select an output
        clicks: 1
        # show the label with the output name
        show_label: true

      region:
        # the output needs to be in the <output>@<x>,<y>,<w>,<h> (e.g. DP-3@2789,436,756,576) format
        command: slurp -f '%o@%x,%y,%w,%h'

      # hide the token restore checkbox and use the default value instead
      hide_token_restore: true
    '';

    home.file.".config/hypr/hyprlock.conf".text = ''
      background {
        monitor =
        path = ~/pictures/wallpaper/tom-vining.jpg
        blur_passes = 3
        contrast = 0.8916
        brightness = 0.8172
        vibrancy = 0.1696
        vibrancy_darkness = 0.0
      }


      auth {
        fingerprint {
          enabled = true
          ready_message = "Scan fingerprint to unlock"
          present_message = "Scanning fingerprint"
        }
      }

      input-field {
        monitor =
        fade_on_empty = false
        outer_color = rgb(c0caf5)
        inner_color = rgb(16161e)
        font_color = rgb(EFEFEF)
        placeholder_text = <i>Input Password...</i>
        hide_input = false
        size = 200, 50

        position= 0, -120
        halign = center
        valign = center
      }

      label {
        monitor =
        text = cmd[update:100] echo "$FPRINTPROMPT"
        color = rgb(EFEFEF)
        font_size = 10
        font_family = FiraCode Nerd Font
        position= 0, -180
        halign = center
        valign = center
      }

      label {
       monitor =
       text = cmd[update:1000] echo $TIME
       color = rgb(EFEFEF)
       font_size = 72
       font_family = FiraCode Nerd Font
       position = 0, -250
       halign = center
       valign = top
      }

      label {
        monitor =
        text = Hi there, $USER
        color = rgba(200, 200, 200, 1.0)
        font_size = 25
        font_family = FiraCode Nerd Font

        position = 0, -40
        halign = center
        valign = center
      }

      label {
          monitor =
          text = cmd[update:1000] echo "$(${location}/bin/location) $(${weather}/bin/weather)"
          color = rgba(255, 255, 255, 1)
          font_size = 10
          font_family = FiraCode Nerd Font Mono ExtraBold
          position = 0, -200
          halign = center
          valign = top
      }
    '';
  };
}
