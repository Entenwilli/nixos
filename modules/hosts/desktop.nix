{
  inputs,
  self,
  ...
}: {
  flake.nixosConfigurations.nixos-desktop = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      inputs.impermanence.nixosModules.impermanence
      inputs.base16.nixosModule
      {
        scheme = "${inputs.color-schemes}/base24/catppuccin-mocha.yaml";
      }
      inputs.sops-nix.nixosModules.sops
      inputs.entenvim.nixosModules.neovim
      self.nixosModules.desktop
      self.nixosModules.desktop-home-manager
    ];
  };

  flake.nixosModules.desktop = {
    pkgs,
    config,
    lib,
    ...
  }: {
    imports = [
      self.nixosModules.desktop-hardware
      self.nixosModules.common
    ];

    # Desktop packages only
    environment.systemPackages = with pkgs; [
      mpvpaper
      btop-rocm
      scrcpy
      android-tools
      via
      wonderdraft
      trackma-gtk
      ryubing
      eclipses.eclipse-modeling
    ];

    # Enable impermanence
    impermanence.enable = true;

    # Setup syncthing
    syncthing.enable = true;
    sops.secrets."syncthing-desktop-key" = {
      restartUnits = ["syncthing.service"];
    };
    syncthing.keySecretName = "syncthing-desktop-key";
    sops.secrets."syncthing-desktop-cert" = {
      restartUnits = ["syncthing.service"];
    };
    syncthing.certSecretName = "syncthing-desktop-cert";

    # Set Hostname
    networking.hostName = "nixos-desktop";

    # Enable gaming tools
    gaming.enable = true;

    # This option defines the first version of NixOS you have installed on this particular machine,
    # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
    #
    # Most users should NEVER change this value after the initial install, for any reason,
    # even if you've upgraded your system to a new NixOS release.
    #
    # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
    # so changing it will NOT upgrade your system.
    #
    # This value being lower than the current NixOS release does NOT mean your system is
    # out of date, out of support, or vulnerable.
    #
    # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
    # and migrated your data accordingly.
    #
    # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
    system.stateVersion = "25.05"; # Did you read the comment?
  };
}
