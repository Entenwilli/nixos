{pkgs, ...}: {
  systemd.user.timers."break" = {
    timerConfig = {
      OnBootSec = "4h";
      Unit = ["break.service"];
    };
    wantedBy = ["timers.target"];
  };
  systemd.user.services."break" = {
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.dunst}/bin/dunstify --hints=\"string:fgcolor:#ff4444\" --appname=\"Time to take a Break!\" --urgency=critical --timeout=0 --icon=\"face-tired\" \"Over 4 hours have elapsed! Did you take a break?\"";
    };
  };

  systemd.user.timers."late" = {
    timerConfig = {
      OnCalendar = "*-*-* 18:00:00";
      Unit = ["late.service"];
    };
    wantedBy = ["timers.target"];
  };
  systemd.user.services."late" = {
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.dunst}/bin/dunstify --hints=\"string:fgcolor:#ff4444\" --appname=\"It\'s getting late!\" --urgency=critical --timeout=0 --icon=\"face-tired\" \"It's 6pm... You should finish work for today!\"";
    };
  };

  systemd.user.timers."bedtime" = {
    timerConfig = {
      OnCalendar = "*-*-* 22:00:00";
      Unit = ["break.service"];
    };
    wantedBy = ["timers.target"];
  };
  systemd.user.services."bedtime" = {
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.dunst}/bin/dunstify --hints=\"string:fgcolor:#ff4444\" --appname=\"It\'s time to go to bed!\" --urgency=critical --timeout=0 --icon=\"face-tired\" \"It's 10pm... You should wrap up and begin going to bed!\"";
    };
  };
}
