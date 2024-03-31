{
  lib,
  pkgs,
  ...
}: {
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    QT_QPA_PLATFORMTHEME = "qt6ct";
  };
 environment.systemPackages = with pkgs; [
    networkmanager_dmenu
    rofi-power-menu
    dmenu-bluetooth
    wirelesstools
    rofi
    wl-clipboard
    hyprpaper
    unstable.hyprlock
    dunst
    unstable.hypridle
    bc
    grim
    slurp
  ];
  programs.hyprland.enable = true;
  xdg.portal.enable = true;
  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
}
