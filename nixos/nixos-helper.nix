{
  lib,
  config,
  ...
}: {
  options = {
    nixos-helper.enable = lib.mkEnableOption "Enable nh the nixos-helper";
  };

  config = lib.mkIf config.nixos-helper.enable {
    programs.nh = {
      enable = true;
      clean.enable = true;
      clean.extraArgs = "--keep-since 4d --keep 3";
      flake = "/home/felix/nixos";
    };
  };
}
