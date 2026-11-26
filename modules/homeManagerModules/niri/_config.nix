{
  cfg,
  lib,
}: let
  kdl = import ./_kdl.nix {inherit lib;};
  inherit (kdl) raw args;
in {
  "spawn-at-startup" = "keepassxc";

  layout = {
    gaps = 16;
    center-focused-column = "never";
    # Cycled through via Mod+R / Mod+Shift+R.
    preset-column-widths = {proportion = [0.33333 0.5 0.66667];};
    default-column-width = {proportion = 0.5;};
    focus-ring = {
      width = 2;
      active-color = "#7fc8ff";
      inactive-color = "#505050";
    };
    border = {off = null;};
    shadow = {
      on = null;
      draw-behind-window = true;
      softness = 30;
      spread = 5;
      offset = {
        "@x" = 0;
        "@y" = 5;
      };
      color = "#0007";
    };
  };

  hotkey-overlay = {skip-at-startup = null;};
  prefer-no-csd = null;
  screenshot-path = "~/pictures/Screenshots/Screenshot from %Y-%m-%d %H-%M-%S.png";
  # Explicit empty block: no animation overrides.
  animations = [];
  blur = {
    passes = 3;
    offset = 3.0;
  };

  window-rule = [
    {
      geometry-corner-radius = 12;
      clip-to-geometry = true;
    }
    {
      match = {"@is-active" = true;};
      opacity = 0.75;
      draw-border-with-background = false;
      background-effect = {blur = true;};
    }
    {
      opacity = 0.6;
      draw-border-with-background = false;
      background-effect = {blur = true;};
    }
    {
      match = {"@app-id" = raw "^zen-twilight$";};
      draw-border-with-background = false;
    }
    {
      match = {
        "@title" = raw "KeePassXC \\-.*";
        "@app-id" = raw "^org\\.keepassxc\\.KeePassXC$";
      };
      open-floating = true;
    }
    {
      match = {
        "@title" = "Locked";
        "@app-id" = raw "^org\\.keepassxc\\.KeePassXC$";
      };
      min-width = 880;
      max-width = 880;
      min-height = 500;
      max-height = 500;
      open-floating = true;
    }
    {
      match = {"@app-id" = "XIVLauncher.Core";};
      open-floating = true;
    }
  ];

  layer-rule = [
    {
      match = [
        {"@namespace" = "rofi";}
        {"@namespace" = "logout_dialog";}
      ];
      background-effect = {
        blur = true;
        xray = false;
      };
    }
    {
      match = {"@namespace" = "entenshell-background-overview$";};
      place-within-backdrop = true;
    }
  ];

  binds = {
    "Mod+Shift+Slash" = {show-hotkey-overlay = null;};
    "Mod+Return" = {
      "@hotkey-overlay-title" = "Open a Terminal: kitty";
      spawn = "kitty";
    };
    "Mod+D" = {
      "@hotkey-overlay-title" = "Run an Application: rofi";
      spawn = args ["rofi" "-show" "drun"];
    };
    "Mod+Period" = {spawn = args ["bemoji" "-t"];};
    "Mod+Shift+Escape" = {
      "@hotkey-overlay-title" = "Lock the screen";
      spawn = args ["entenshell" "ipc" "call" "lock" "lock"];
    };

    "XF86AudioRaiseVolume" = {
      "@allow-when-locked" = true;
      spawn-sh = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.1+ -l 1.0";
    };
    "XF86AudioLowerVolume" = {
      "@allow-when-locked" = true;
      spawn-sh = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.1-";
    };
    "XF86AudioMute" = {
      "@allow-when-locked" = true;
      spawn-sh = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
    };
    "XF86AudioMicMute" = {
      "@allow-when-locked" = true;
      spawn-sh = "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle";
    };
    "XF86AudioPlay" = {
      "@allow-when-locked" = true;
      spawn-sh = "playerctl play-pause";
    };
    "XF86AudioStop" = {
      "@allow-when-locked" = true;
      spawn-sh = "playerctl stop";
    };
    "XF86AudioPrev" = {
      "@allow-when-locked" = true;
      spawn-sh = "playerctl previous";
    };
    "XF86AudioNext" = {
      "@allow-when-locked" = true;
      spawn-sh = "playerctl next";
    };
    "XF86MonBrightnessUp" = {
      "@allow-when-locked" = true;
      spawn = args ["brightnessctl" "--class=backlight" "set" "+10%"];
    };
    "XF86MonBrightnessDown" = {
      "@allow-when-locked" = true;
      spawn = args ["brightnessctl" "--class=backlight" "set" "10%-"];
    };

    # Open/close the Overview: a zoomed-out view of workspaces and
    # windows. Can also be reached by moving the mouse into the
    # top-left hot corner, or a four-finger swipe up on a touchpad.
    "Mod+O" = {
      "@repeat" = false;
      toggle-overview = null;
    };

    "Mod+Shift+Q" = {
      "@repeat" = false;
      close-window = null;
    };

    "Mod+Left" = {focus-column-left = null;};
    "Mod+Down" = {focus-window-down = null;};
    "Mod+Up" = {focus-window-up = null;};
    "Mod+Right" = {focus-column-right = null;};
    "Mod+H" = {focus-column-left = null;};
    "Mod+J" = {focus-window-down = null;};
    "Mod+K" = {focus-window-up = null;};
    "Mod+L" = {focus-column-right = null;};

    "Mod+Ctrl+Left" = {move-column-left = null;};
    "Mod+Ctrl+Down" = {move-window-down = null;};
    "Mod+Ctrl+Up" = {move-window-up = null;};
    "Mod+Ctrl+Right" = {move-column-right = null;};
    "Mod+Ctrl+H" = {move-column-left = null;};
    "Mod+Ctrl+J" = {move-window-down = null;};
    "Mod+Ctrl+K" = {move-window-up = null;};
    "Mod+Ctrl+L" = {move-column-right = null;};

    # Alternative binds that move across workspaces when reaching the
    # first/last window in a column, instead of stopping there:
    #   Mod+J          { focus-window-or-workspace-down; }
    #   Mod+K          { focus-window-or-workspace-up; }
    #   Mod+Ctrl+J     { move-window-down-or-to-workspace-down; }
    #   Mod+Ctrl+K     { move-window-up-or-to-workspace-up; }

    "Mod+Home" = {focus-column-first = null;};
    "Mod+End" = {focus-column-last = null;};
    "Mod+Ctrl+Home" = {move-column-to-first = null;};
    "Mod+Ctrl+End" = {move-column-to-last = null;};

    "Mod+Shift+Left" = {focus-monitor-left = null;};
    "Mod+Shift+Down" = {focus-monitor-down = null;};
    "Mod+Shift+Up" = {focus-monitor-up = null;};
    "Mod+Shift+Right" = {focus-monitor-right = null;};
    "Mod+Shift+H" = {focus-monitor-left = null;};
    "Mod+Shift+J" = {focus-monitor-down = null;};
    "Mod+Shift+K" = {focus-monitor-up = null;};
    "Mod+Shift+L" = {focus-monitor-right = null;};

    "Mod+Shift+Ctrl+Left" = {move-column-to-monitor-left = null;};
    "Mod+Shift+Ctrl+Down" = {move-column-to-monitor-down = null;};
    "Mod+Shift+Ctrl+Up" = {move-column-to-monitor-up = null;};
    "Mod+Shift+Ctrl+Right" = {move-column-to-monitor-right = null;};
    "Mod+Shift+Ctrl+H" = {move-column-to-monitor-left = null;};
    "Mod+Shift+Ctrl+J" = {move-column-to-monitor-down = null;};
    "Mod+Shift+Ctrl+K" = {move-column-to-monitor-up = null;};
    "Mod+Shift+Ctrl+L" = {move-column-to-monitor-right = null;};

    # Alternatively, single-window variants exist (move-window-to-
    # monitor-*), as do whole-workspace variants (move-workspace-to-
    # monitor-*), both bindable on the same Mod+Shift+Ctrl+<dir> keys.

    "Mod+Page_Down" = {focus-workspace-down = null;};
    "Mod+Page_Up" = {focus-workspace-up = null;};
    "Mod+U" = {focus-workspace-down = null;};
    "Mod+I" = {focus-workspace-up = null;};
    "Mod+Ctrl+Page_Down" = {move-column-to-workspace-down = null;};
    "Mod+Ctrl+Page_Up" = {move-column-to-workspace-up = null;};
    "Mod+Ctrl+U" = {move-column-to-workspace-down = null;};
    "Mod+Ctrl+I" = {move-column-to-workspace-up = null;};

    # Alternatively: Mod+Ctrl+Page_Down { move-window-to-workspace-down; }

    "Mod+Shift+Page_Down" = {move-workspace-down = null;};
    "Mod+Shift+Page_Up" = {move-workspace-up = null;};
    "Mod+Shift+U" = {move-workspace-down = null;};
    "Mod+Shift+I" = {move-workspace-up = null;};

    # cooldown-ms rate-limits mouse-wheel binds so scrolling doesn't fly
    # through workspaces too fast; direction follows natural-scroll.
    "Mod+WheelScrollDown" = {
      "@cooldown-ms" = 150;
      focus-workspace-down = null;
    };
    "Mod+WheelScrollUp" = {
      "@cooldown-ms" = 150;
      focus-workspace-up = null;
    };
    "Mod+Ctrl+WheelScrollDown" = {
      "@cooldown-ms" = 150;
      move-column-to-workspace-down = null;
    };
    "Mod+Ctrl+WheelScrollUp" = {
      "@cooldown-ms" = 150;
      move-column-to-workspace-up = null;
    };

    "Mod+WheelScrollRight" = {focus-column-right = null;};
    "Mod+WheelScrollLeft" = {focus-column-left = null;};
    "Mod+Ctrl+WheelScrollRight" = {move-column-right = null;};
    "Mod+Ctrl+WheelScrollLeft" = {move-column-left = null;};

    # Shift+wheel replicates the horizontal-scroll convention apps use.
    "Mod+Shift+WheelScrollDown" = {focus-column-right = null;};
    "Mod+Shift+WheelScrollUp" = {focus-column-left = null;};
    "Mod+Ctrl+Shift+WheelScrollDown" = {move-column-right = null;};
    "Mod+Ctrl+Shift+WheelScrollUp" = {move-column-left = null;};

    # Touchpad scroll ticks are also bindable (split into discrete
    # intervals, since touchpad scrolling is continuous), e.g.:
    #   Mod+TouchpadScrollDown { spawn-sh "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.02+"; }
    #   Mod+TouchpadScrollUp   { spawn-sh "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.02-"; }
    # (inverted here since natural-scroll is on for touchpads by default)

    # Mod+1..9 focus workspaces by index. Niri's workspaces are dynamic,
    # so this is "best effort": an index beyond the current count just
    # refers to the bottommost (empty) workspace.
    "Mod+1" = {focus-workspace = 1;};
    "Mod+2" = {focus-workspace = 2;};
    "Mod+3" = {focus-workspace = 3;};
    "Mod+4" = {focus-workspace = 4;};
    "Mod+5" = {focus-workspace = 5;};
    "Mod+6" = {focus-workspace = 6;};
    "Mod+7" = {focus-workspace = 7;};
    "Mod+8" = {focus-workspace = 8;};
    "Mod+9" = {focus-workspace = 9;};
    "Mod+Shift+1" = {move-column-to-workspace = 1;};
    "Mod+Shift+2" = {move-column-to-workspace = 2;};
    "Mod+Shift+3" = {move-column-to-workspace = 3;};
    "Mod+Shift+4" = {move-column-to-workspace = 4;};
    "Mod+Shift+5" = {move-column-to-workspace = 5;};
    "Mod+Shift+6" = {move-column-to-workspace = 6;};
    "Mod+Shift+7" = {move-column-to-workspace = 7;};
    "Mod+Shift+8" = {move-column-to-workspace = 8;};
    "Mod+Shift+9" = {move-column-to-workspace = 9;};

    # Alternatively: Mod+Ctrl+1 { move-window-to-workspace 1; }
    # Switch focus between current/previous workspace:
    #   Mod+Tab { focus-workspace-previous; }

    # If the focused window is alone, Mod+BracketLeft/Right consume it
    # into the nearby column; if it's already in a column, they expel it.
    "Mod+BracketLeft" = {consume-or-expel-window-left = null;};
    "Mod+BracketRight" = {consume-or-expel-window-right = null;};

    # Alternatively, consume/expel a single window from the right/bottom
    # of the focused column:
    #   Mod+Comma  { consume-window-into-column; }
    #   Mod+Period { expel-window-from-column; }

    "Mod+R" = {switch-preset-column-width = null;}; # cycles preset-column-widths
    "Mod+Shift+R" = {switch-preset-column-width-back = null;}; # ...in reverse

    "Mod+Ctrl+Shift+R" = {switch-preset-window-height = null;};
    "Mod+Ctrl+R" = {reset-window-height = null;};

    "Mod+F" = {maximize-column = null;};
    "Mod+Shift+F" = {fullscreen-window = null;};

    # Unlike maximize-column (which leaves gaps/borders),
    # maximize-window-to-edges expands the window to the screen
    # edges - the usual double-click-titlebar "maximize".
    "Mod+M" = {maximize-window-to-edges = null;};

    # Expands the focused column into space not already taken up by
    # other fully visible columns.
    "Mod+Ctrl+F" = {expand-column-to-available-width = null;};

    "Mod+C" = {center-column = null;};
    "Mod+Ctrl+C" = {center-visible-columns = null;}; # centers all visible columns

    # set-column-width/set-window-height accept absolute pixels
    # ("1000"), relative pixels ("+5"/"-5"), absolute percent ("25%"),
    # or relative percent ("+10%"/"-10%"), in logical/scaled pixels.
    "Mod+Minus" = {set-column-width = "-10%";};
    "Mod+Equal" = {set-column-width = "+10%";};
    "Mod+Shift+Minus" = {set-window-height = "-10%";};
    "Mod+Shift+Equal" = {set-window-height = "+10%";};

    "Mod+V" = {toggle-window-floating = null;};
    "Mod+Shift+V" = {switch-focus-between-floating-and-tiling = null;};

    # Tabbed columns show their windows as vertical tabs instead of
    # stacked on top of each other.
    "Mod+W" = {toggle-column-tabbed-display = null;};

    # Alternative layout-switch binds exist:
    #   Mod+Space       { switch-layout "next"; }
    #   Mod+Shift+Space { switch-layout "prev"; }
    # Don't enable these alongside a matching xkb layout-switch hotkey -
    # having both switches twice per press (once via xkb, once via niri).

    "Print" = {screenshot = null;};
    "Ctrl+Print" = {screenshot-screen = null;};
    "Alt+Print" = {screenshot-window = null;};

    # allow-inhibiting=false makes niri always process this bind even
    # when a remote-desktop client or software KVM has inhibited
    # keyboard shortcuts - an escape hatch so such a client can't hold
    # the session hostage.
    "Mod+Escape" = {
      "@allow-inhibiting" = false;
      toggle-keyboard-shortcuts-inhibit = null;
    };

    "Mod+Shift+E" = {spawn = args ["entenshell" "ipc" "call" "powermenu" "toggle"];}; # shows a confirmation dialog
    "Mod+Shift+W" = {spawn = args ["entenshell" "ipc" "call" "wallpaper" "open"];};
  };

  debug = {render-drm-device = "/dev/dri/renderD129";};

  input = {
    keyboard = {
      xkb = {layout = cfg.keyboardLayout;};
      numlock = null;
    };
    touchpad = {
      tap = null;
      natural-scroll = null;
    };
    mouse = {
      accel-profile = "flat";
      accel-speed = 0.5;
    };
    focus-follows-mouse = null;
  };
}
