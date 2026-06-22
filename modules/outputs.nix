{lib, ...}: {
  options.flake.homeManagerModules = lib.mkOption {
    default = {};
    type = lib.types.lazyAttrsOf lib.types.raw;
  };
}
