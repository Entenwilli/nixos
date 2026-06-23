{
  lib,
  input,
  ...
}: {
  flake.homeManagerModules.niri = {
    pkgs,
    config,
    ...
  }: {
    home.file.".config/niri/config.kdl" = {
      force = true;
      text = lib.readFile ./config.kdl;
    };
  };
}
