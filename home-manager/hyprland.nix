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
      package = inputs.hyprland.packages.${pkgs.system}.hyprland;
      systemd.enable = true;
      systemd.enableXdgAutostart = true;
      importantPrefixes = ["$" "name" "bezier" "output"];
      settings = {
        monitorv2 = builtins.map ({
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
            supports_wide_color = hdr;
            supports_hdr = hdr;
            sdr_min_luminance = sdr_min_luminance;
            sdr_max_luminance = sdr_max_luminance;
          })
        config.hyprland.monitors;

        experimental = {
          xx_color_management_v4 = true;
        };

        "$terminal" = "${pkgs.kitty}/bin/kitty";
        "$menu" = "${pkgs.rofi-wayland}/bin/rofi -modi drun,run -show drun";

        input = {
          kb_layout = config.hyprland.keyboardLayout;
          kb_variant = "altgr-intl";
          follow_mouse = "1";
          touchpad = {
            natural_scroll = "no";
          };
          sensitivity = "-0.3";
        };

        general = {
          gaps_in = 5;
          gaps_out = 10;
          border_size = 2;
          "col.active_border" = "rgba(33ccffee) rgba(00ff99ee) 45deg";
          "col.inactive_border" = "rgba(595959aa)";
          layout = "dwindle";
          allow_tearing = false;
        };

        animations = {
          enabled = "yes";
          bezier = "myBezier, 0.05, 0.9, 0.1, 1.05";
          animation = [
            "windows, 1, 7, myBezier"
            "windowsOut, 1, 7, default, popin 80%"
            "border, 1, 10, default"
            "borderangle, 1, 8, default"
            "fade, 1, 7, default"
            "workspaces, 1, 6, default"
          ];
        };

        dwindle = {
          pseudotile = "yes";
          preserve_split = "yes";
        };

        misc = {
          disable_hyprland_logo = 1;
          disable_splash_rendering = 1;
        };

        windowrulev2 = [
          "opacity 0.90 0.85,class:^(kitty)$"

          "opacity 0.90 0.85,class:^(anki)$"

          "opacity 0.90 0.85,class:^(WebCord)$"
          "workspace 5, class:^(WebCord)$"

          "opacity 0.90 0.85,title:^(Rofi.*)$"

          "opacity 0.90 0.85,class:^(neovide)$"

          "float, class:^org\\.keepassxc\\.KeePassXC$, title:^Unlock Database - KeePassXC$"
          "center, class:^org\\.keepassxc\\.KeePassXC$, title:^Unlock Database - KeePassXC$"

          "float, class:^org\\.keepassxc\\.KeePassXC$, title:^KeePassXC - Browser Access Request$"
          "center, class:^org\\.keepassxc\\.KeePassXC$, title:^KeePassXC - Browser Access Request$"

          "float, class:^org\\.keepassxc\\.KeePassXC$, title:^.*\\[Locked\\] - KeePassXC"
          "size 880 500, class:^org\\.keepassxc\\.KeePassXC$, title:^.*\\[Locked\\] - KeePassXC"

          "workspace 2, class:^floorp$"

          "opacity 0.90 0.85,class:^(obsidian)$"

          "float, class:^(ueberzug.*)$"
          "noanim, class:^(ueberzug.*)$"
          "noborder, class:^(ueberzug.*)$"
          "noshadow, class:^(ueberzug.*)$"

          "size 150 150, class:cover"
        ];

        layerrule = [
          "blur,rofi"
        ];

        "$mainMod" = "SUPER";
        "$mainModShift" = "SUPER_SHIFT";

        bind = [
          "$mainMod, Return, exec, $terminal"
          "$mainModShift, Q, killactive"
          "$mainModShift, E, exec, rofi -show p -modi p:'rofi-power-menu'"
          "$mainMod, V, togglefloating"
          "$mainMod, D, exec, $menu"
          "$mainMod, P, pseudo"
          "$mainMod, J, togglesplit"
          "$mainMod, F, fullscreen"
          "$mainMod, left, movefocus, l"
          "$mainMod, right, movefocus, r"
          "$mainMod, up, movefocus, u"
          "$mainMod, down, movefocus, d"
          "$mainMod, 1, workspace, 1"
          "$mainMod, 2, workspace, 2"
          "$mainMod, 3, workspace, 3"
          "$mainMod, 4, workspace, 4"
          "$mainMod, 5, workspace, 5"
          "$mainMod, 6, workspace, 6"
          "$mainMod, 7, workspace, 7"
          "$mainMod, 8, workspace, 8"
          "$mainMod, 9, workspace, 9"
          "$mainMod, 0, workspace, 10"
          "$mainMod SHIFT, 1, movetoworkspace, 1"
          "$mainMod SHIFT, 2, movetoworkspace, 2"
          "$mainMod SHIFT, 3, movetoworkspace, 3"
          "$mainMod SHIFT, 4, movetoworkspace, 4"
          "$mainMod SHIFT, 5, movetoworkspace, 5"
          "$mainMod SHIFT, 6, movetoworkspace, 6"
          "$mainMod SHIFT, 7, movetoworkspace, 7"
          "$mainMod SHIFT, 8, movetoworkspace, 8"
          "$mainMod SHIFT, 9, movetoworkspace, 9"
          "$mainMod SHIFT, 0, movetoworkspace, 10"
          "$mainMod, S, togglespecialworkspace, magic"
          "$mainMod SHIFT, S, movetoworkspace, special:magic"
          "$mainMod, mouse_down, workspace, e+1"
          "$mainMod, mouse_up, workspace, e-1"
          ",XF86AudioRaiseVolume,       exec, ${volume}/bin/volume inc 3"
          ",XF86AudioLowerVolume,       exec, ${volume}/bin/volume dec 3"
          ",XF86AudioMute,              exec, ${volume}/bin/volume mute"
          ",XF86AudioPlay,              exec, playerctl play-pause"
          ",XF86AudioPause,             exec, playerctl play-pause"
          ",XF86MonBrightnessUp,        exec, /home/felix/.config/scripts/backlight.sh inc 5"
          ",XF86MonBrightnessDown,      exec, /home/felix/.config/scripts/backlight.sh dec 5"
          "$mainMod,Period,             exec, ${pkgs.bemoji}/bin/bemoji -t"
        ];
        bindm = [
          "$mainMod, mouse:272, movewindow"
          "$mainMod, mouse:273, resizewindow"
        ];
        debug = {
          disable_logs = false;
        };
      };
      extraConfig = lib.strings.concatStrings [
        ''
          env = QT_QPA_PLATFORMTHEME,qt6ct
          env = XDG_SESSION_TYPE,wayland

          exec-once = hyprlock;
          exec-once = hypridle;
          exec-once = systemctl --user start hyprpolkitagent;
          exec-once = keepassxc;
          exec-once = ${pkgs.clipse}/bin/clipse -listen;
          exec-once = fcitx5 -d

          exec-once = dbus-update-activation-environment --systemd --all
          exec-once = systemctl --user import-environment QT_QPA_PLATFORMTHEME DBUS_SESSION_ADDRESS

          master {
              new_status = master
          }
        ''
        (
          if (config.hyprland.hyprpaper.enable)
          then ''
            exec-once = hyprpaper;
          ''
          else ''
            exec-once = mpvpaper -o '--gpu-api=vulkan --hwdec=auto --vulkan-device="00000000-1200-0000-0000-000000000000" no-audio --loop-playlist shuffle' ALL ~/pictures/wallpaper/video/flower-shop-beachside.mp4;
          ''
        )
        config.hyprland.additional_config
      ];
    };

    services.hyprpaper = {
      enable = config.hyprland.hyprpaper.enable;
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
