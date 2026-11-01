{...}: {
  flake.nixosModules.host-role = {lib, ...}: {
    options.hostRole = lib.mkOption {
      type = lib.types.enum ["desktop" "laptop" "server"];
      description = "Which configuration (desktop/laptop/server) is currently being built.";
    };
  };
}
