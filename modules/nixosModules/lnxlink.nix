{...}: {
  flake.nixosModules.lnxlink = {
    pkgs,
    config,
    ...
  }: {
    systemd.user.services.lnxlink = {
      serviceConfig = {
        ExecStart = "${pkgs.lnxlink}/bin/lnxlink -c ${config.home-manager.users.felix.sops.secrets."desktop-lnxlink.yml".path} -i";
        Restart = "always";
        RestartSec = "5";
      };
      path = with pkgs; [
        ethtool
        gawk
        steam
        wl-clipboard
        sudo
      ];
      wantedBy = ["default.target"];
    };
  };
}
