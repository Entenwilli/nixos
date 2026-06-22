{...}: {
  flake.nixosModules.bluetooth = {
    pkgs,
    config,
    ...
  }: {
    hardware.bluetooth = {
      enable = true;
      powerOnBoot = false;
    };
  };
}
