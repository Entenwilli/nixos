{
  pkgs,
  lib,
  config,
  ...
}: let
  wallpaper-switcher = pkgs.writeShellApplication {
    name = "wallpaper-switcher";
    text =
      if (config.hyprland.hyprpaper.enable)
      then ''
        wallpaper_dir="$HOME/pictures/wallpaper/desktop"
        selected_wallpaper=$(for a in "$wallpaper_dir"/*.png; do echo -en "$a\0icon\x1f$a\n" ; done | rofi -dmenu -theme wallpaper-switcher -p "Select a wallpaper:")
        current_monitor=$(hyprctl monitors -j | jq -r '.[] | select(.focused==true) | .name')
        echo "Switching wallpaper for $current_monitor to $selected_wallpaper"
        hyprctl hyprpaper reload "$current_monitor","$selected_wallpaper"

      ''
      else ''
        wallpaper_dir="$HOME/pictures/wallpaper/video"
        mapfile -t wallpapers < <(ls "$wallpaper_dir")
        wallpaper_list=$(printf "%s\n" "''${wallpapers[@]}")
        selected_wallpaper=$(echo -e "$wallpaper_list" | rofi -dmenu -p "Select a wallpaper:")
        wallpaper_path="$wallpaper_dir/$selected_wallpaper"
        pkill .mpvpaper-wrapp
        echo "Switching to wallpaper at $wallpaper_path"
        mpvpaper -o '--gpu-api=vulkan --hwdec=auto --vulkan-device="00000000-1200-0000-0000-000000000000" no-audio --loop-playlist shuffle' ALL "$wallpaper_path" &
      '';
  };
in {
  options.wallpaper-switcher = {
    enable = lib.mkEnableOption "Enable wallpaper switcher";
  };

  config = lib.mkIf config.wallpaper-switcher.enable {
    xdg.desktopEntries.wallpaper-switcher = {
      name = "Wallpaper Switcher";
      exec = "${wallpaper-switcher}/bin/wallpaper-switcher";
    };

    home.packages = with pkgs; [
      rofi-wayland
      wallpaper-switcher
    ];
    xdg.dataFile."rofi/themes/wallpaper-switcher.rasi".text = ''
      @import "~/.config/rofi/config.rasi"
      configuration {
        modi: "drun";
      }

      window {
        width: 75%;
        height: inherit;
      }

      mainbox {
        children:
          [ "inputbar", "listview"];
      }

      entry {
        expand: true;
        placeholder: "Search / Choose Wallpaper";
        horizontal-align: 0.5;
        horizontal-align: 0.5;
      }

      listview {
        spacing: 20px;
        padding: 10px;
        columns: 4;
        lines: 3;
        flow: horizontal;
        fixed-width: true;
        fixed-height: true;
        cycle: true;
      }

      element {
        orientation: vertical;
        padding: 0px;
        spacing: 0px;
        border-radius: 10px;
        padding: 0px;
        margin: 0px;
      }

      element selected.normal {
        background-color: #C51E3A;
      }

      element-icon {
          text-color:                  inherit;
          size:                        10%;
          margin:                      0px;
          cursor:                      inherit;
      }

      element-text {
        vertical-align: 0.5;
        horizontal-align: 0.5;
        padding: 6px;
        margin: 6px;
      }
    '';
  };
}
