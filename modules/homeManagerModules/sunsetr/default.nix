{
  self,
  inputs,
  lib,
  ...
}: {
  flake.homeManagerModules.sunsetr = {
    pkgs,
    config,
    ...
  }: {
    options = {
      sunsetr.enable = lib.mkEnableOption "Enable sunsetr";
    };

    config = lib.mkIf config.sunsetr.enable {
      home.packages = with pkgs; [sunsetr];

      systemd.user.services.sunsetr = {
        Unit = {
          Description = "Sunsetr - Automatic blue light filter for Hyprland, Niri, and everything Wayland";
          Documentation = "https://github.com/psi4j/sunsetr?tab=readme-ov-file#sunsetr";
          PartOf = ["graphical-session.target"];
          Requires = ["graphical-session.target"];
          After = ["graphical-session.target"];
          ConditionEnvironment = "WAYLAND_DISPLAY";
        };

        Service = {
          Type = "simple";
          ExecStart = lib.getExe pkgs.sunsetr;
          Restart = "on-failure";
          RestartSec = 30;
          Slice = "background.slice";
          ConfigurationDirectory = "sunsetr";
          ConfigurationDirectoryMode = 0700;
        };

        Install.WantedBy = ["graphical-session.target"];
      };

      home.file.".config/sunsetr/sunsetr.toml".source = (pkgs.formats.toml {}).generate "sunsetr.toml" {
        backend = "auto";
        transition_mode = "start_at";

        smoothing = true;

        night_temp = 3300;
        day_temp = 6500;
        night_gamma = 80;
        day_gamma = 100;
        update_interval = "auto";

        sunset = "19:00:00";
        sunrise = "06:00:00";
        transition_duration = 90;
      };
    };
  };
}
