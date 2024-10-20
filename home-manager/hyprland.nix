{
  lib,
  pkgs,
  config,
  ...
}: let
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
    nvidiaFixes = lib.mkEnableOption "Enable Nvidia Fixes";
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
          settings = lib.mkOption {
            type = lib.types.str;
            description = ''
              Hyprland settings string for monitor
            '';
          };
          wallpaper = lib.mkOption {
            type = lib.types.str;
            description = ''
              Path to the monitor wall paper
            '';
          };
        };
      });
    };
  };

  config = lib.mkIf config.hyprland.enable {
    wayland.windowManager.hyprland = {
      enable = true;
      package = pkgs.unstable.hyprland;
      systemd.enable = true;
      settings = {
        monitor = builtins.map ({
          name,
          settings,
          ...
        }: "${name},${settings}")
        config.hyprland.monitors;

        "$terminal" = "${pkgs.kitty}/bin/kitty";
        "$menu" = "${pkgs.rofi-wayland}/bin/rofi -modi drun,run -show drun";

        input = {
          follow_mouse = "1";
          touchpad = {
            natural_scroll = "no";
          };
          sensitivity = "-0.3";
        };

        general = {
          gaps_in = 5;
          gaps_out = 20;
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

        gestures = {
          workspace_swipe = "on";
        };

        misc = {
          disable_hyprland_logo = 1;
          disable_splash_rendering = 1;
        };

        windowrulev2 = [
          "opacity 0.80 0.75,class:^(kitty)$"

          "opacity 0.80 0.75,class:^(anki)$"

          "opacity 0.80 0.75,class:^(WebCord)$"
          "workspace 5, class:^(WebCord)$"

          "opacity 0.80 0.75,title:^(Rofi.*)$"

          "opacity 0.80 0.75,class:^(SWT)$"
          "float,title:^(This product Launcher.*)$"

          "opacity 0.80 0.75,class:^(neovide)$"

          "opacity 0.80 0.75,title:^(spotify_player)$"
          "workspace 4, title:^(spotify_player)$"

          "float, class:^(org.keepassxc.KeePassXC)$, title:^(KeePassXC -  Access Request)$"
          "center, class:^(org.keepassxc.KeePassXC)$, title:^(KeePassXC -  Access Request)$"

          "workspace 2, class:^(firefox)$"

          "opacity 0.80 0.75,class:^(obsidian)$"
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
          ",XF86AudioRaiseVolume,       exec, /home/felix/.config/scripts/volume.sh inc 3"
          ",XF86AudioLowerVolume,       exec, /home/felix/.config/scripts/volume.sh dec 3"
          ",XF86AudioMute,              exec, /home/felix/.config/scripts/volume.sh mute"
          ",XF86AudioPlay,              exec, playerctl play-pause"
          ",XF86AudioPause,             exec, playerctl play-pause"
          ",XF86MonBrightnessUp,        exec, /home/felix/.config/scripts/backlight.sh inc 5"
          ",XF86MonBrightnessDown,      exec, /home/felix/.config/scripts/backlight.sh dec 5"
          "$mainMod,Period,             exec, bemoji"
        ];
        bindm = [
          "$mainMod, mouse:272, movewindow"
          "$mainMod, mouse:273, resizewindow"
        ];

        debug = {
          disable_logs = false;
        };

        cursor = lib.mkIf config.hyprland.nvidiaFixes {
          no_hardware_cursors = true;
        };
      };
      extraConfig = ''
        env = QT_QPA_PLATFORMTHEME,qt6ct
        env = LIBVA_DRIVER_NAME,nvidia
        env = GBM_BACKEND,nvidia-drm
        env = __GLX_VENDOR_LIBRARY_NAME,nvidiaA
        env = XDG_SESSION_TYPE,wayland

        exec-once = hyprlock;
        exec-once = hyprpaper;
        exec-once = hypridle;
        exec-once = keepassxc;
        exec-once = spotify_player -d;

        exec-once = dbus-update-activation-environment --systemd --all
        exec-once = systemctl --user import-environment QT_QPA_PLATFORMTHEME DBUS_SESSION_ADDRESS

        device {
           name = keychron-keychron-q1-keyboard
           kb_layout = us
           kb_variant = altgr-intl
         }

         device {
           name = keychron-keychron-q1
           kb_layout = us
           kb_variant = altgr-intl
         }

          master {
              new_status = master
          }
      '';
    };

    services.hyprpaper = {
      enable = true;
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
          on-timeout = brightnessctl -s set 10
          on-resume = brightnessctl -r
      }

      listener {
          timeout = 150
          on-timeout = brightnessctl -sd rgb:kbd_backlight set 0
      }

      listener {
          timeout = 300
          on-timeout = hyprctl dispatch dpms off
          on-resume = hyprctl dispatch dpms on
      }
    '';

    home.file.".config/hypr/hyprlock.conf".text = ''
      background {
        monitor =
        path = ~/Bilder/Wallpaper/nighttime-in-the-mountains.png
        blur_passes = 3
        contrast = 0.8916
        brightness = 0.8172
        vibrancy = 0.1696
        vibrancy_darkness = 0.0
      }

      general {
        no_fade_in = false
        grace = 0
        disable_loading_bar = true
      }

      input-field {
        monitor =
        fade_on_empty = false
        outer_color = rgb(c0caf5)
        inner_color = rgb(16161e)
        font_color = rgb(EFEFEF)
        color = rgb(EFEFEF)
        placeholder_text = <i>Input Password...</i>
        hide_input = false
        size = 200, 50

        position= 0, -120
        halign = center
        valign = center
      }

      label {
       monitor =
       text = cmd[update:1000] echo "$(date +"%-H:%M")"
       color = rgb(EFEFEF)
       font_size = 72
       font_family = FiraCode Nerd Font
       position = 0, -300
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
          position = 0, 350
          halign = center
          valign = center
      }
    '';
  };
}
