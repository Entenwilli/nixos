{
  libs,
  pkgs,
  inputs,
  ...
}: let
  system = pkgs.system;
in {
  programs.entenvim.enable = true;
}
