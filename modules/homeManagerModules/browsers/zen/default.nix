{
  self,
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
      self.homeManagerModules.zen-browser-extensions
      self.homeManagerModules.zen-browser-pins
      self.homeManagerModules.zen-browser-policies
      self.homeManagerModules.zen-browser-spaces
    ];

    options.zen-browser = {
      enable = lib.mkEnableOption "Enable Zen Browser";
      defaultBrowser = lib.mkOption {
        default = false;
        description = "Enable default browser";
        type = lib.types.bool;
      };
    };

    config = lib.mkIf config.zen-browser.enable {
      xdg.mimeApps.enable = config.zen-browser.defaultBrowser;
      programs.zen-browser = {
        enable = true;
        setAsDefaultBrowser = config.zen-browser.defaultBrowser;

        nativeMessagingHosts = with pkgs; [
          keepassxc
          yomitan-api
          yomitan-mecab
        ];

        profiles."default" = {
          isDefault = true;
          settings = {
            "zen.welcome-screen.seen" = true;
            "zen.workspaces.continue-where-left-off" = true;
          };

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
