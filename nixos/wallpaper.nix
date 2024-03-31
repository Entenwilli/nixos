{
  config,
  lib,
  pkgs,
  ...
}: {
  options.wallpaper = {
    path = lib.mkOption {
      description = "Mappings from screen to path"
      type = lib.types.listOf(attrset(string | path))
    }
  }
}
