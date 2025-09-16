# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).
{
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
    ../notifications.nix
    ../../shells
  ];

  nixpkgs.config.rocmSupport = true;
  virtualisation.docker.enable = true;

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
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    localNetworkGameTransfers.openFirewall = true;
    gamescopeSession = {
      enable = true;
    };
    package = pkgs.steam.override {
      extraProfile = ''
        unset TZ
      '';
    };
    extraCompatPackages = with pkgs; [proton-ge-bin];
  };

  programs.gamemode.enable = true;
  programs.gamescope.enable = true;

  # Desktop packages only
  environment.systemPackages = with pkgs; [
    mpvpaper
    xivlauncher
    gamemode
    btop-rocm
    scrcpy
    android-tools
    v4l-utils
    mangohud
    via
    lact
    prismlauncher
    krita
  ];

  hardware.opentabletdriver = {
    enable = true;
    daemon.enable = true;
  };

  boot.extraModprobeConfig = ''
    options amdgpu ppfeaturemask=0xFFF7FFFF
    options v4l2loopback devices=2 video_nr=0,1 card_label="Webcam,OBS Virtual Cam" exclusive_caps=1,1
  '';

  programs.obs-studio.enable = true;
  programs.obs-studio.enableVirtualCamera = true;
  programs.obs-studio.plugins = with pkgs.obs-studio-plugins; [
    obs-ndi
    wlrobs
    obs-backgroundremoval
    obs-pipewire-audio-capture
    obs-composite-blur
    obs-shaderfilter
    obs-scale-to-sound
    obs-move-transition
    obs-gradient-source
    obs-replay-source
    obs-source-clone
    obs-3d-effect
    obs-livesplit-one
    waveform
    obs-gstreamer
    obs-vaapi
    obs-vkcapture
  ];

  programs.streamcontroller.enable = true;

  programs.noisetorch.enable = true;
  systemd.user.services.noisetorch = {
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.noisetorch}/bin/noisetorch -i 'alsa_input.usb-M-Audio_M-Track_2X2-00.analog-stereo'";
    };
    wantedBy = ["graphical-session.target"];
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

  # Set Hostname
  networking.hostName = "nixos-desktop";

  hardware.graphics = {
    enable = true;
    package = pkgs.mesa;
    enable32Bit = true;
    extraPackages = with pkgs; [
      rocmPackages.clr.icd
    ];
  };

  hardware.amdgpu = {
    initrd.enable = true;
  };

  services.hardware.openrgb = {
    enable = true;
    motherboard = "amd";
  };

  systemd.packages = with pkgs; [lact];
  systemd.services.lactd.wantedBy = ["multi-user.target"];

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
