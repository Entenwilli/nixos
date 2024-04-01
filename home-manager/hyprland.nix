{
  libs,
  pkgs,
  ...
}: {
   home.file.".config/hypr/hyprlock.conf".text = ''
   background {
     monitor =
     path = ~/pictures/Wallpaper/nighttime-in-the-mountains.png
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
  '';

}
