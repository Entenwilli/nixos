{
  lib,
  pkgs,
  config,
  ...
}: {
  options = {
    dunst.enable = lib.mkEnableOption "Enable dunst";
  };

  config = lib.mkIf config.dunst.enable {
    home.packages = with pkgs; [papirus-icon-theme];
    services.dunst = {
      enable = true;
      iconTheme = {
        name = "Papirus-Dark";
        package = pkgs.papirus-icon-theme;
        size = "32x32";
      };
      settings = {
        global = {
          # Set notification format
          markup = "full";
          ignore_newline = "no";
          format = "<b>%a</b>\\n<i>%s</i>\\n\\n%b";

          # Set font
          font = "FiraCode Nerd Font 11";

          icon_path = "${pkgs.papirus-icon-theme}/share/icons/Papirus-Dark/symbolic/status";

          # Follow monitor with mouse
          follow = "mouse";

          # Dimensions
          width = 300;
          offset = "0x24";
          origin = "top-center";

          # Enable progressbar
          progress_bar = true;
          progress_bar_height = 14;
          progress_bar_frame_width = 1;
          progress_bar_min_width = 150;
          progress_bar_max_width = 300;

          # Show how many messages are hidden
          indicate_hidden = "yes";

          # Shrink window if it's smaller than the width
          shrink = "no";

          # Set transparency of notification window
          transparency = 1;

          # Draw lines between multiple notifications
          seperator_height = 6;
          seperator_color = config.scheme.withHashtag.base04;

          # Notification padding
          padding = 16;
          horizontal_padding = 16;

          # Disable frame border
          frame_width = 0;

          # Sort messages by urgency
          sort = "no";

          # Disable idle time
          idle_threshold = 0;

          # Text line height
          line_height = 0;

          # Text alignment
          alignment = "left";
          vertical_alignment = "left";

          # Show age of messages
          show_age_threshold = 120;

          # Wrap Text
          word_wrap = "yes";

          # Don't stack together notifications
          stack_duplicates = false;

          # Display indicators
          show_indicators = "no";

          # ------ Icons -------
          # Alignment
          icon_position = "left";

          # Icon size
          # min_icon_size = 50;
          # max_icon_size = 60;

          # ------- History ------
          # Avoid timing out hidden notifications
          sticky_history = "yes";

          # Maximum history length
          history_length = 100;

          # ------- Misc -------
          dmenu = "${pkgs.rofi-wayland}/bin/rofi -dmenu -p dunst:";
          browser = "${pkgs.firefox}/bin/firefox -new-tab";

          # Window manager options
          title = "Dunst";
          class = "Dunst";

          # Set rounded corners
          corner_radius = 10;

          # Don't ignore the dbus close notification message
          ignore_dbusclose = false;
        };

        urgency_low = {
          background = config.scheme.withHashtag.base00;
          foreground = config.scheme.withHashtag.base06;
          frame_color = config.scheme.withHashtag.base04;
          highlight = config.scheme.withHashtag.base0E;
          timeout = 2;
        };

        urgency_normal = {
          background = config.scheme.withHashtag.base00;
          foreground = config.scheme.withHashtag.base05;
          frame_color = config.scheme.withHashtag.base04;
          highlight = config.scheme.withHashtag.base0E;
          timeout = 2;
        };

        urgency_critical = {
          background = config.scheme.withHashtag.base00;
          foreground = config.scheme.withHashtag.base0F;
          frame_color = config.scheme.withHashtag.base04;
          highlight = config.scheme.withHashtag.base0E;
          timeout = 10;
        };

        backlight = {
          appname = "Backlight";
          highlight = config.scheme.withHashtag.base0A;
        };

        music = {
          appname = "Music";
        };

        volume = {
          summary = "Volume*";
          highlight = config.scheme.withHashtag.base0E;
        };

        battery = {
          appname = "Power Warning";
        };
      };
    };
  };
}
