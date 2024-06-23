{
  lib,
  config,
  inputs,
  pkgs,
  ...
}: let
  inherit
    (inputs.nix-colors.lib-contrib {inherit pkgs;})
    gtkThemeFromScheme
    ;
in {
  options = {
    theming.enable = lib.mkEnableOption "Enable theming settings";
  };

  config = lib.mkIf config.theming.enable {
    home.packages = with pkgs; [
      adwaita-qt
      papirus-icon-theme
      libsForQt5.qt5ct
      qt6Packages.qt6ct
      tokyo-night-gtk
    ];

    home.pointerCursor = {
      gtk.enable = true;
      x11.enable = true;
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Ice";
      size = 1;
    };

    qt = {
      enable = true;
      platformTheme = "gtk";
      style.name = "adwaita-dark";
      style.package = pkgs.adwaita-qt;
    };

    gtk = {
      enable = true;
      gtk3.extraConfig.gtk-application-prefer-dark-theme = true;
      gtk4.extraConfig.gtk-application-prefer-dark-theme = true;

      theme = {
        name = "${config.colorScheme.slug}";
        package = gtkThemeFromScheme {scheme = config.colorScheme;};
      };
    };
  };
}
