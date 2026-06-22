{
  inputs,
  self,
  ...
}: {
  flake.nixosModules.desktop-home-manager = {
    imports = [inputs.home-manager.nixosModules.home-manager];

    home-manager = {
      useGlobalPkgs = true;
      extraSpecialArgs.hasGlobalPkgs = true;
      backupFileExtension = "backup";
      sharedModules = [
        inputs.sops-nix.homeManagerModules.sops
      ];

      users.felix.imports = [
        self.homeManagerModules.desktop-home
        self.homeManagerModules.common
      ];
    };
  };

  flake.homeManagerModules.desktop-home = {
    pkgs,
    config,
    ...
  }: {
    hyprland.monitors = [
      {
        name = "DP-3";
        mode = "2560x1440@144";
        position = "0x0";
        scale = 1.0;
        hdr = true;
        sdr_min_luminance = 0.005;
        sdr_max_luminance = 200;
        wallpaper = "/home/felix/pictures/wallpaper/snowy-lake.jpg";
      }
      {
        name = "DP-2";
        mode = "2560x1440@144";
        position = "2560x0";
        scale = 1.0;
        hdr = true;
        sdr_min_luminance = 0.005;
        sdr_max_luminance = 200;
        wallpaper = "/home/felix/pictures/wallpaper/nighttime-in-the-mountains.png";
      }
      {
        name = "HDMI-A-1";
        mode = "2560x1600@60";
        position = "5120x0";
        scale = "1.0";
        sdr_min_luminance = 0.005;
        sdr_max_luminance = 200;
        wallpaper = "/home/felix/pictures/wallpaper/nighttime-in-the-mountains.png";
      }
    ];

    # Enable impermanence
    impermanence.enable = true;
  };
}
