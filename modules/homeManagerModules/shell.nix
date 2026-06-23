{
  inputs,
  lib,
  ...
}: {
  flake.homeManagerModules.shell = {
    pkgs,
    config,
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
      };

      Service = {
        ExecStart = lib.getExe package;
        Restart = "on-failure";
      };

      Install.WantedBy = ["graphical.target"];
    };
  };
}
