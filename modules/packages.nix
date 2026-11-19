{...}: {
  perSystem = {pkgs, ...}: let
    names = builtins.attrNames (import ../pkgs {inherit pkgs; prev = pkgs;});
  in {
    packages = pkgs.lib.genAttrs names (name: pkgs.${name});
  };
}
