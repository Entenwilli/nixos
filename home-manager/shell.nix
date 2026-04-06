{
  inputs,
  lib,
  pkgs,
  ...
}: let
  package =
    inputs.entenshell.packages.${pkgs.stdenv.hostPlatform.system}.entenshell;
in {
  home.packages = [
    package
  ];

  systemd.user.services.quickshell = {
    Unit = {
      Description = "quickshell";
      Documentation = "https://quickshell.outfoxxed.me/docs/";
      After = ["hyprland-session.target"];
    };

    Service = {
      ExecStart = lib.getExe package;
      Restart = "on-failure";
    };

    Install.WantedBy = ["hyprland-session.target"];
  };
}
