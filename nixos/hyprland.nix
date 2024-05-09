{
  lib,
  pkgs,
  ...
}: {
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    QT_QPA_PLATFORMTHEME = "qt6ct";
    # HACK: Fix crash in newer eclipse versions
    WEBKIT_DISABLE_DMABUF_RENDERER = "1";
  };
  environment.systemPackages = with pkgs; [
    networkmanager_dmenu
    rofi-power-menu
    dmenu-bluetooth
    wirelesstools
    rofi-wayland
    wl-clipboard
    hyprpaper
    unstable.hyprlock
    dunst
    unstable.hypridle
    bc
    grim
    slurp
    rofi-emoji
  ];

  programs.hyprland = {
    enable = true;
    package = pkgs.unstable.hyprland;
  };
  xdg.portal.enable = true;
  xdg.portal.extraPortals = [pkgs.xdg-desktop-portal-gtk];
}
