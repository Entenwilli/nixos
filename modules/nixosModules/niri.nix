{
  lib,
  inputs,
  ...
}: {
  flake.nixosModules.niri = {
    pkgs,
    config,
    ...
  }: {
    programs.niri = {
      enable = true;
      useNautilus = false;
    };

    environment.systemPackages = with pkgs; [
      xwayland-satellite
    ];

    services.gnome.gcr-ssh-agent.enable = lib.mkForce false;
  };
}
