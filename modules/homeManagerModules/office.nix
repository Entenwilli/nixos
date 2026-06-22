{...}: {
  flake.homeManagerModules.office = {
    pkgs,
    config,
    lib,
    ...
  }: {
    options = {
      office.enable = lib.mkEnableOption "Enable office tools";
    };
    config = lib.mkIf config.office.enable {
      home.packages = with pkgs; [
        thunderbird
        obsidian
        pympress
      ];
    };
  };
}
