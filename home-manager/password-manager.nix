{
  lib,
  pkgs,
  config,
  ...
}: {
  options = {
    password-manager = {
      enable = lib.mkEnableOption "Enable KeePassXC as password manager";
    };
  };
  config = lib.mkIf config.password-manager.enable {
    home.packages = with pkgs; [
      libsecret
      keepassxc
    ];
  };
}
