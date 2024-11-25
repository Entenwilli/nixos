{pkgs, ...}: {
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    QT_QPA_PLATFORMTHEME = "qt6ct";
  };
  environment.systemPackages = with pkgs; [
    networkmanager_dmenu
    dmenu-bluetooth
    wirelesstools
    wl-clipboard
    hyprpaper
    hyprlock
    dunst
    hypridle
    bc
    grim
    slurp
    hyprsunset
    hyprpolkitagent
  ];

  programs.hyprland = {
    enable = true;
    package = pkgs.hyprland;
    portalPackage = pkgs.xdg-desktop-portal-hyprland;
  };
  xdg.portal.enable = true;
  xdg.portal.extraPortals = [pkgs.xdg-desktop-portal-gtk];
}
