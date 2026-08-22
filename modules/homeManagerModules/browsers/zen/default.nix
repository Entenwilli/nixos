{
  inputs,
  lib,
  ...
}: {
  flake.homeManagerModules.zen-browser = {
    pkgs,
    config,
    ...
  }: {
    imports = [
      inputs.zen-browser.homeModules.twilight
    ];

    options = {
      zen-browser.enable = lib.mkEnableOption "Enable Zen Browser";
    };

    config = lib.mkIf config.zen-browser.enable {
      programs.zen-browser = {
        enable = true;
        profiles."default" = {
          isDefault = true;
          settings = {
            "zen.welcome-screen.seen" = true;
            "zen.workspaces.continue-where-left-off" = true;
          };

          # TODO: Can also add native messaging hosts for yomitan and mecab api here
          # Should be a package/derivation exposing native messaging host file under lib/mozilla/native-messaging-hosts/<NAME>.json
          nativeMessagingHosts.packages = with pkgs; [
            keepassxc
          ];

          # No containers because of bugs with extensions
          containersForce = true;
          containers = {};

          # Search
          search = {
            force = true;
            default = "ddg";
          };

          # Styling
          presets.catppuccin = {
            enable = true;
            flavor = "Mocha";
            accent = "Mauve";
          };
        };
      };
    };
  };
}
