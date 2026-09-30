{lib, ...}: {
  flake.nixosModules.niri = {pkgs, ...}: {
    programs.niri = {
      enable = true;
      useNautilus = false;
    };

    services.gnome.gnome-keyring.enable = lib.mkForce false;

    environment.systemPackages = with pkgs; [
      unstable.xwayland-satellite
    ];

    services.gnome.gcr-ssh-agent.enable = lib.mkForce false;
  };
}
