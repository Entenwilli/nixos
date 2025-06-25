{pkgs, ...}: {
  systemd.user.timers."break" = {
    timerConfig = {
      OnBootSec = "4h";
    };
    wantedBy = ["timers.target"];
  };
  systemd.user.services."break" = {
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.dunst}/bin/dunstify --hints=\"string:fgcolor:#ff4444\" --appname=\"Time to take a Break!\" --urgency=critical --timeout=0 --icon=\"face-tired\" \"Over 4 hours have elapsed! Did you take a break?\"";
    };
    wantedBy = ["break.timer"];
  };

  systemd.user.timers."late" = {
    timerConfig = {
      OnCalendar = "*-*-* 18:00:00";
    };
    wantedBy = ["timers.target"];
  };
  systemd.user.services."late" = {
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.dunst}/bin/dunstify --hints=\"string:fgcolor:#ff4444\" --appname=\"It\'s getting late!\" --urgency=critical --timeout=0 --icon=\"face-tired\" \"It's 6pm... You should finish work for today!\"";
    };
    wantedBy = ["late.timer"];
  };
}
