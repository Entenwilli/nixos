{
  inputs,
  self,
  ...
}: {
  flake.nixosModules.laptop-home-manager = {
    imports = [inputs.home-manager.nixosModules.home-manager];

    home-manager = {
      useGlobalPkgs = true;
      extraSpecialArgs.hasGlobalPkgs = true;
      backupFileExtension = "backup";
      sharedModules = [
        inputs.sops-nix.homeManagerModules.sops
      ];

      users.felix.imports = [
        self.homeManagerModules.laptop-home
        self.homeManagerModules.common
      ];
    };
  };

  flake.homeManagerModules.laptop-home = {
    pkgs,
    config,
    ...
  }: {
    hyprland.monitors = [
      {
        name = "eDP-1";
        mode = "1920x1200@60";
        position = "0x0";
        scale = 1.0;
        hdr = false;
        sdr_min_luminance = 0.005;
        sdr_max_luminance = 200;
        wallpaper = "/home/felix/pictures/wallpaper/tom-vining.jpg";
      }
    ];

    hyprland.keyboardLayout = "de";
  };
}
