{lib, ...}: {
  flake.homeManagerModules.theming = {
    pkgs,
    config,
    ...
  }: {
    options = {
      theming.enable = lib.mkEnableOption "Enable theming settings";
    };

    config = lib.mkIf config.theming.enable {
      home.packages = with pkgs; [
        papirus-icon-theme
        libsForQt5.qt5ct
        qt6Packages.qt6ct
        (catppuccin-kde.override
          {
            flavour = ["mocha"];
            accents = ["mauve"];
          })
      ];

      home.pointerCursor = {
        gtk.enable = true;
        x11.enable = true;
        package = pkgs.catppuccin-cursors.mochaMauve;
        name = "catppuccin-mocha-mauve-cursors";
        size = 16;
      };

      qt = {
        enable = true;
        #FIXME: Remove darkly-qt5 and flake input when qt5 is no longer used
        style.package = with pkgs; [(lib.hiPrio darkly) pkgs.darkly_nixpkgs.darkly-qt5];
        platformTheme.name = "qtct";
      };

      gtk = {
        enable = true;
        colorScheme = "dark";
        gtk3.extraConfig.gtk-application-prefer-dark-theme = true;
        gtk4.extraConfig.gtk-application-prefer-dark-theme = true;
        gtk4.theme = config.gtk.theme;

        theme = {
          name = "catppuccin-mocha-mauve-standard";
          package = pkgs.catppuccin-gtk.override {
            variant = "mocha";
            accents = ["mauve"];
          };
        };
      };
      xdg.configFile = let
        gtk4Dir = "${config.gtk.theme.package}/share/themes/${config.gtk.theme.name}/gtk-4.0";
      in {
        "gtk-4.0/assets".source = "${gtk4Dir}/assets";
        "gtk-4.0/gtk.css".source = "${gtk4Dir}/gtk.css";
        "gtk-4.0/gtk-dark.css".source = "${gtk4Dir}/gtk-dark.css";

        "kdeglobals".text = ''
          [UiSettings]
          ColorScheme=Catppuccin-mocha-mauve
        '';
      };
    };
  };
}
