{
  lib,
  pkgs,
  ...
}: {
  # Rquired theming packages
  home.packages = with pkgs; [
    papirus-icon-theme
    libsForQt5.qt5ct
    qt6Packages.qt6ct
  ];

  home.sessionVariables.QT_QPA_PLATFORMTHEME = "qt6ct";

  # GTK Theming
  gtk = {
    enable = true;
    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = true;
    };
    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = true;
    };
  };
}
