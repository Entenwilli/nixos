{...}: {
  flake.nixosModules.drawing = {
    pkgs,
    config,
    ...
  }: {
    environment.systemPackages = with pkgs; [
      krita
    ];
    hardware.opentabletdriver = {
      enable = true;
      daemon.enable = true;
    };

    systemd.user.services.csp-prewarm = {
      serviceConfig = {
        Type = "simple";
        Environment = "WINEPREFIX=/home/felix/.wine-csp/";
        ExecStartPre = "-${pkgs.wine64Packages.unstableFull}/bin/wineserver -k";
        ExecStart = "${pkgs.wine64Packages.unstableFull}/bin/wineserver -f";
        Restart = "always";
      };
      wantedBy = ["default.target"];
      after = ["default.target"];
    };
  };
}
