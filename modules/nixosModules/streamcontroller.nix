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
      wantedBy = ["graphical.target"];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.unstable.streamcontroller}/bin/streamcontroller -b";
      };
      path = with pkgs; [
        playerctl
        config.programs.hyprland.package
        mpv
        procps
      ];
    };
  };
}
