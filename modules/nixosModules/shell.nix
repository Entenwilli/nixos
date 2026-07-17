{
  inputs,
  lib,
  ...
}: {
  flake.nixosModules.shell = {
    pkgs,
    config,
    ...
  }: let
    package =
      inputs.entenshell.packages.${pkgs.stdenv.hostPlatform.system}.entenshell;
  in {
    environment.systemPackages = [
      package
    ];

    systemd.packages = [package];
    services.dbus.packages = [package];

    systemd.user.services.quickshell = {
      partOf = ["graphical-session.target"];
      after = ["graphical-session.target"];
      requisite = ["graphical-session.target"];
      description = "quickshell";
      documentation = ["https://quickshell.outfoxxed.me/docs/"];

      serviceConfig = {
        ExecStart = lib.getExe package;
        restart = "on-failure";
      };

      wantedBy = ["graphical-session.target"];
    };
  };
}
