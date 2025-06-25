{pkgs, ...}: let
  hyprsunset-check = pkgs.writeShellApplication {
    name = "hyprsunset-boot";
    text = ''
      H=$(date +%H)
      if (( 10#$H <= 8 || 10#$H >= 18 )); then
        ${pkgs.systemd}/bin/systemctl --user start hyprsunset.service
      fi
    '';
  };
in {
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    QT_QPA_PLATFORMTHEME = "qt6ct";
  };
  environment.systemPackages = with pkgs; [
    networkmanager_dmenu
    dmenu-bluetooth
    wirelesstools
    wl-clipboard
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
    wantedBy = ["timers.target"];
  };

  systemd.user.services."hyprsunset" = {
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.hyprsunset}/bin/hyprsunset -t 3500";
    };
  };

  systemd.user.services."hyprsunset-boot" = {
    serviceConfig = {
      Type = "simple";
      ExecStart = "${hyprsunset-check}/bin/hyprsunset-boot";
    };
    wantedBy = ["graphical-session.target"];
  };

  systemd.user.timers."hyprsunset-disable" = {
    timerConfig = {
      OnCalendar = "*-*-* 07:00:00";
    };
    wantedBy = ["timers.target"];
  };

  systemd.user.services."hyprsunset-disable" = {
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.systemd}/bin/systemctl --user stop hyprsunset";
    };
  };
}
