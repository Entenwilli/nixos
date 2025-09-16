{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    krita
  ];
  hardware.opentabletdriver = {
    enable = true;
    daemon.enable = true;
  };
}
