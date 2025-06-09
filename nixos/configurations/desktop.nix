# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).
{
  lib,
  config,
  pkgs,
  ...
}: {
  imports = [
    # Include the results of the hardware scan.
    ./desktop-hardware.nix

    ../secrets.nix
    ../hyprland.nix
    ../network.nix
    ../nixos-helper.nix
    ../syncthing.nix
    ../common.nix
    ../../shells
  ];

  sops.secrets."github-token-desktop" = {
    owner = "felix";
  };
  nix.extraOptions = ''
    !include ${config.sops.secrets."github-token-desktop".path}
  '';

  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/efi";

  # Use grub bootloader
  boot.loader = {
    grub = {
      enable = true;
      efiSupport = true;
      devices = ["nodev"];
      extraEntries = ''
        menuentry "Windows 11" --class windows {
          insmod part_gpt
          insmod fat
          insmod search_fs_uuid
          insmod chain
          search --fs-uuid --set=root 9237-E870
          chainloader /EFI/Microsoft/Boot/bootmgfw.efi
        }
      '';
      gfxmodeEfi = "1920x1080";
      gfxpayloadEfi = "keep";
      theme = "${pkgs.catppuccin-grub}";
      splashImage = "${pkgs.catppuccin-grub}/background.png";
    };
  };
  boot.supportedFilesystems = ["ntfs"];

  # Enable steam
  programs.steam.enable = true;
  programs.steam.package = pkgs.steam.override {
    extraProfile = ''
      unset TZ
    '';
  };
  environment.systemPackages = with pkgs; [mpvpaper xivlauncher gamemode];

  programs.noisetorch.enable = true;

  # Setup syncthing
  services = {
    syncthing = {
      enable = true;
      user = "felix";
      dataDir = "/home/felix";
      configDir = "/home/felix/.config/syncthing";
    };
  };

  # Set Hostname
  networking.hostName = "nixos-desktop";

  hardware.graphics = {
    enable = true;
    package = pkgs.unstable.mesa;
    enable32Bit = true;
  };

  hardware.amdgpu = {
    initrd.enable = true;
  };

  services.xserver.videoDrivers = ["amdgpu"];

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
}
