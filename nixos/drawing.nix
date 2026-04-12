{
  pkgs,
  inputs,
  ...
}: {
  environment.systemPackages = with pkgs; [
    krita
    #inputs.csp.packages.${pkgs.stdenv.hostPlatform.system}.clip-studio-paint-v4
  ];
  hardware.opentabletdriver = {
    enable = true;
    daemon.enable = true;
  };
}
