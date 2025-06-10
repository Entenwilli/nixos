# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).
{
  inputs,
  lib,
  config,
  pkgs,
  ...
}: {
  imports = [
    # Include the results of the hardware scan.
    inputs.hardware.nixosModules.dell-xps-13-9310
    ./laptop-hardware.nix

    ../secrets.nix
    ../hyprland.nix
    ../network.nix
    ../laptop.nix
    ../nixos-helper.nix
    ../common.nix
    ../notifications.nix
    ../../shells
  ];
  sops.secrets."github-token-laptop" = {
    owner = "felix";
  };
  nix.extraOptions = ''
    !include ${config.sops.secrets."github-token-laptop".path}
  '';
  # Use the systemd-boot EFI boot loader.
  boot.loader.efi.canTouchEfiVariables = true;

  # Use grub bootloader
  boot.loader = {
    grub = {
      enable = true;
      device = "nodev";
      efiSupport = true;
      gfxmodeEfi = lib.mkForce "1920x1200";
      gfxpayloadEfi = "keep";
      theme = "${pkgs.catppuccin-grub}";
      splashImage = "${pkgs.catppuccin-grub}/background.png";
    };
  };

  # Set console keymap to german keyboard
  console = {
    keyMap = "de-latin1";
  };

  # Setup syncthing
  services = {
    syncthing = {
      enable = true;
      user = "felix";
      dataDir = "/home/felix";
      configDir = "/home/felix/.config/syncthing";
    };
  };

  environment.systemPackages = with pkgs; [
    brightnessctl
  ];

  # Setup upower agent
  services.upower.enable = true;

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      mesa
      intel-media-driver
      libva
    ];
    extraPackages32 = with pkgs.driversi686Linux; [
      mesa
      intel-media-driver
    ];
  };

  # Set hostname
  networking.hostName = "nixos-laptop";
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
  system.stateVersion = "23.11"; # Did you read the comment?
}
