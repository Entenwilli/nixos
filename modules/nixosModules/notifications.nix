{...}: {
  flake.nixosModules.notifications = {
    pkgs,
    config,
    ...
  }: {
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
        Environment = ["DISPLAY=:0"];
        ExecStart = ''${pkgs.libnotify}/bin/notify-send -u critical -t 0 -i face-tired -h "string:fgcolor:#ff4444" -a "Time to take a Break!" "Over 4 hours have elapsed! Did you take a break?"'';
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
        Environment = ["DISPLAY=:0"];
        ExecStart = ''${pkgs.libnotify}/bin/notify-send -u critical -t 0 -i face-tired -h "string:fgcolor:#ff4444" -a "It's getting late!" "It's 6pm... You should finish work for today!"'';
      };
    };

    systemd.user.timers."bedtime" = {
      timerConfig = {
        OnCalendar = "*-*-* 22:00:00";
        Unit = ["bedtime.service"];
      };
      wantedBy = ["timers.target"];
    };
    systemd.user.services."bedtime" = {
      serviceConfig = {
        Type = "simple";
        Environment = ["DISPLAY=:0"];
        ExecStart = ''${pkgs.libnotify}/bin/notify-send -u critical -t 0 -i face-tired -h "string:fgcolor:#ff4444" -a "It's time to go to bed!" "It's 10pm... You should wrap up and begin going to bed!"'';
      };
    };
  };
}
