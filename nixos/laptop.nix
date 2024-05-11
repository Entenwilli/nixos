{pkgs, ...}: let
  battery-notify = pkgs.writeShellApplication {
    name = "battery-notify";

    text = ''
      if [ "$1" == "charging" ]
        then
        DISPLAY=:0 ${pkgs.dunst}/bin/dunstify -i battery-good-charging-symbolic -h "string:fgcolor:#44ff44" -a "System" "Power cable plugged in."
      elif [ "$1" == "discharging" ]
        then
        DISPLAY=:0 ${pkgs.dunst}/bin/dunstify -i battery-low-symbolic -h "string:fgcolor:#ff4444" -a "System" "Power cable unplugged."
      fi
    '';
  };
in {
  services.thermald.enable = true;

  services.auto-cpufreq.enable = true;
  services.auto-cpufreq.settings = {
    battery = {
      governor = "powersave";
      turbo = "never";
    };
    charger = {
      governor = "performance";
      turbo = "auto";
    };
  };

  services.udev.enable = true;
  services.udev.extraRules = ''
    SUBSYSTEM=="power_supply", ACTION=="change", ENV{POWER_SUPPLY_ONLINE}=="0", RUN+="${pkgs.systemd}/bin/systemctl --no-block start battery-notify-udev@discharging.service"
    SUBSYSTEM=="power_supply", ACTION=="change", ENV{POWER_SUPPLY_ONLINE}=="1", RUN+="${pkgs.systemd}/bin/systemctl --no-block start battery-notify-udev@charging.service"
  '';

  systemd.services."battery-notify-udev@" = {
    environment = {
      DBUS_SESSION_BUS_ADDRESS = "unix:path=/run/user/1000/bus";
    };
    serviceConfig = {
      User = "felix";
      Type = "oneshot";
      ExecStart = "${pkgs.systemd}/bin/systemctl --user start battery-notify@%i.service";
    };
  };

  systemd.user.services."battery-notify@" = {
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${battery-notify}/bin/battery-notify %i";
    };
  };
}
