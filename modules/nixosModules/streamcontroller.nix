{...}: {
  flake.nixosModules.streamcontroller = {
    pkgs,
    config,
    ...
  }: {
    programs.streamcontroller = {
      enable = true;
      package = pkgs.unstable.streamcontroller;
    };
    systemd.user.services."streamcontroller" = {
      partOf = ["graphical-session.target"];
      after = ["graphical-session.target"];
      requisite = ["graphical-session.target"];
      wantedBy = ["graphical-session.target"];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.unstable.streamcontroller}/bin/streamcontroller -b";
      };
      path = with pkgs; [
        playerctl
        config.programs.hyprland.package
        config.programs.niri.package
        mpv
        procps
      ];
    };
  };
}
