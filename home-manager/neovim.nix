{
  inputs,
  pkgs,
  ...
}: let
  system = pkgs.system;
in {
  programs.neovim = inputs.entenvim.lib.mkHomeManager {inherit system;};
}
