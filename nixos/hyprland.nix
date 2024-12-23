{pkgs, ...}: {
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    QT_QPA_PLATFORMTHEME = "qt6ct";
  };
  environment.systemPackages = with pkgs; [
    networkmanager_dmenu
    dmenu-bluetooth
    wirelesstools
    wl-clipboard
    hyprpaper
    unstable.hyprlock
    dunst
    hypridle
    bc
    grim
    slurp
    hyprsunset
    hyprpolkitagent
  ];

  programs.hyprland = {
    enable = true;
    package = pkgs.hyprland;
    portalPackage = pkgs.xdg-desktop-portal-hyprland;
  };
  xdg.portal.enable = true;
  xdg.portal.extraPortals = [pkgs.xdg-desktop-portal-gtk];

  security.pam.services.hyprlock = {
    name = "hyprlock";
    text = ''
      # PAM configuration file for hyprlock
      # the 'login' configuration file (see /etc/pam.d/login)

      auth        include     login
    '';
  };

  systemd.user.timers."hyprsunset" = {
    timerConfig = {
      OnCalendar = "*-*-* 18:00:00";
    };
  };

  systemd.user.services."hyprsunset" = {
    serviceConfig = {
      Type = "simple";
      ExecCondition = "${pkgs.systemd}/bin/systemctl is-active graphical.target";
      ExecStart = "${pkgs.hyprsunset}/bin/hyprsunset -t 5500";
    };
  };

  systemd.user.timers."hyprsunset-disable" = {
    timerConfig = {
      OnCalendar = "*-*-* 07:00:00";
    };
  };

  systemd.user.services."hyprsunset-disable" = {
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.systemd}/bin/systemctl --user stop hyprsunset";
    };
  };
}
