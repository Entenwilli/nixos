{...}: {
  flake.nixosModules.notifications = {
    pkgs,
    lib,
    ...
  }: let
    mkNotification = {
      name,
      schedule,
      title,
      message,
      icon ? "dialog-information",
      color ? null,
      urgency ? "normal",
    }: let
      colorHint = lib.optionalString (color != null) " -h \"string:fgcolor:${color}\"";
    in {
      systemd.user.timers.${name} = {
        timerConfig = schedule // {Unit = ["${name}.service"];};
        wantedBy = ["timers.target"];
      };
      systemd.user.services.${name} = {
        serviceConfig = {
          Type = "simple";
          Environment = ["DISPLAY=:0"];
          ExecStart = ''${pkgs.libnotify}/bin/notify-send -u ${urgency} -t 0 -i ${icon}${colorHint} -a "${title}" "${message}"'';
        };
      };
    };
  in
    lib.foldl' lib.recursiveUpdate {} (map mkNotification [
      {
        name = "break";
        schedule = {OnBootSec = "4h";};
        title = "Time to take a Break!";
        message = "Over 4 hours have elapsed! Did you take a break?";
        icon = "face-tired";
        color = "#d20f39";
        urgency = "critical";
      }
      {
        name = "late";
        schedule = {OnCalendar = "*-*-* 18:00:00";};
        title = "It's getting late!";
        message = "It's 6pm... You should finish work for today!";
        icon = "face-tired";
        color = "#d20f39";
        urgency = "critical";
      }
      {
        name = "bedtime";
        schedule = {OnCalendar = "*-*-* 22:00:00";};
        title = "It's time to go to bed!";
        message = "It's 10pm... You should wrap up and begin going to bed!";
        icon = "face-tired";
        color = "#d20f39";
        urgency = "critical";
      }
    ]);
}
