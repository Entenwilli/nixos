{
  lib,
  input,
  ...
}: {
  flake.homeManagerModules.niri = {
    pkgs,
    config,
    ...
  }: let
    kdl = import ./_kdl.nix {inherit lib;};
    cfg = config.niri;
  in {
    options.niri = {
      enable = lib.mkEnableOption "Enable niri";

      keyboardLayout = lib.mkOption {
        type = lib.types.str;
        default = "us(altgr-intl)";
      };
    };

    config = lib.mkIf cfg.enable {
      home.file.".config/niri/config.kdl" = {
        force = true;
        text = kdl.toKDL (import ./_config.nix {inherit cfg lib;});
      };
    };
  };
}
