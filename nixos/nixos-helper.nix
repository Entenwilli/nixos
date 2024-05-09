{
  lib,
  pkgs,
  config,
  ...
}: {
  options = {
    nixos-helper.enable = lib.mkEnableOption "Enable nh the nixos-helper";
  };

  config = lib.mkIf config.nixos-helper.enable {
    environment.systemPackages = with pkgs; [unstable.nh];
    /*
    TODO: Add when nh is in stable
    programs.nh = {
      enable = true;
      clean.enable = true;
      clean.extraArgs = "--keep-since 4d --keep 3";
      flake = "/home/felix/nixos";
    };
    */
  };
}
