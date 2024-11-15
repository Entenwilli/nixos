{
  inputs,
  pkgs,
  ...
}: {
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
    unstable.hyprlock
    dunst
    unstable.hypridle
    bc
    grim
    slurp
  ];

  programs.hyprland = {
    enable = true;
    package = pkgs.hyprland-patched;
    portalPackage = pkgs.xdg-desktop-portal-hyprland-patched;
  };
  xdg.portal.enable = true;
  xdg.portal.extraPortals = [pkgs.xdg-desktop-portal-gtk];
}
