{
  lib,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    papirus-icon-theme
  ];

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
