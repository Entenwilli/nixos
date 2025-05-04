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
        menuentry "Windows 11" {
          insmod part_gpt
          insmod fat
          insmod search_fs_uuid
          insmod chain
          search --fs-uuid --set=root 462A-1D52
          chainloader /EFI/Microsoft/Boot/bootmgfw.efi
        }
      '';
      gfxmodeEfi = lib.mkForce "2560x1440";
      gfxpayloadEfi = "keep";
      theme = "${pkgs.catppuccin-grub}";
      splashImage = "${pkgs.catppuccin-grub}/background.png";
    };
  };
  boot.supportedFilesystems = ["ntfs"];

  # Enable steam
  programs.steam.enable = true;
  # Setup syncthing
  sops.secrets."syncthing-desktop-key" = {
    owner = "felix";
    group = "users";
    restartUnits = ["syncthing.service"];
  };
  sops.secrets."syncthing-desktop-cert" = {
    owner = "felix";
    group = "users";
    restartUnits = ["syncthing.service"];
  };
  syncthing.enable = true;
  syncthing.keySecretName = "syncthing-desktop-key";
  syncthing.certSecretName = "syncthing-desktop-cert";

  # Set Hostname
  networking.hostName = "nixos-desktop";

  # Nvidia Stuff
  services.xserver.videoDrivers = ["nvidia"];
  hardware.nvidia = {
    powerManagement.enable = true;
    modesetting.enable = true;
    open = false;
  };
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      nvidia-vaapi-driver
      vaapiVdpau
      libvdpau-va-gl
      libva
    ];
  };
  boot.kernelParams = lib.optionals (lib.elem "nvidia" config.services.xserver.videoDrivers) [
    "nvidia-drm.modeset=1"
    "nvidia_drm.fbdev=1"
    "quiet"
    "splash"
    "rd.udev.log-priority=3"
    "perf_event_paranoid=1"
    "kptr_restrict=0"
  ];

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
