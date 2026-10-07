{
  self,
  inputs,
  lib,
  ...
}: {
  flake.nixosModules.virtualization = {
    pkgs,
    config,
    ...
  }: {
    imports = [
    ];

    options = {
      virtualization.enable = lib.mkEnableOption "Enable virtualization tools";
    };

    config = lib.mkIf config.virtualization.enable {
      virtualisation.podman = {
        enable = true;
        autoPrune.enable = true;
      };
    };
  };
}
