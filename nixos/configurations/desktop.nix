# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).
{
  inputs,
  outputs,
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
    ../../shells
  ];

  # Configure nix package manager
  nixpkgs = {
    overlays = [
      outputs.overlays.additions
      outputs.overlays.modifications
      outputs.overlays.unstable-packages
    ];
    config = {
      allowUnfree = true;
    };
  };

  # This will add each flake input as a registry
  # To make nix3 commands consistent with your flake
  nix.registry = (lib.mapAttrs (_: flake: {inherit flake;})) ((lib.filterAttrs (_: lib.isType "flake")) inputs);

  # This will additionally add your inputs to the system's legacy channels
  # Making legacy nix commands consistent as well, awesome!
  nix.nixPath = ["/etc/nix/path"];
  environment.etc =
    lib.mapAttrs'
    (name: value: {
      name = "nix/path/${name}";
      value.source = value.flake;
    })
    config.nix.registry;

  # NixOS Configuration
  nix.settings = {
    # Enable flakes and new 'nix' command
    experimental-features = "nix-command flakes";
    # Deduplicate and optimize nix store
    auto-optimise-store = true;
  };

  sops.secrets."github-token" = {
    owner = "felix";
  };
  nix.extraOptions = ''
    !include ${config.sops.secrets."github-token".path}
  '';

  # Enable nixos-helper
  nixos-helper.enable = true;

  services.dbus = {
    enable = true;
    packages = with pkgs; [dunst];
  };

  # Use the systemd-boot EFI boot loader.
  #boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Use systemd-boot bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.efiSysMountPoint = "/efi";
  boot.loader.systemd-boot.xbootldrMountPoint = "/boot";

  # Boot splash screen
  boot.consoleLogLevel = 0;
  boot.kernelParams = ["quiet" "splash" "rd.udev.log-priority=3"];
  boot.initrd.verbose = false;
  boot.plymouth = {
    enable = true;
  };

  # Enable display manager
  services.xserver.enable = true;
  services.xserver.displayManager = {
    sddm = {
      enable = true;
      wayland.enable = true;
      settings = {
        Autologin = {
          Session = "hyprland.desktop";
          User = "felix";
        };
      };
    };
  };

  environment.sessionVariables = {
    EDITOR = "nvim";
  };

  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  # Enable steam
  programs.steam.enable = true;

  # Enable fish
  programs.fish.enable = true;
  users.defaultUserShell = pkgs.fish;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.felix = {
    hashedPassword = "$y$j9T$hHy3Jnr8hvdSqLRV3z2760$G.Hr/DOnqhA6c2IfcAcPDGByVm8EOrtvKTnrGKYPodB";
    uid = 1000;
    isNormalUser = true;
    shell = pkgs.fish;
    extraGroups = ["wheel" "audio" "network" "networkmanager" "docker"]; # Enable ‘sudo’ for the user.
    packages = with pkgs; [
      eza
      firefox
    ];
  };

  virtualisation.docker.enable = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    age
    sops
    git
    fastfetch
    rustc
    cargo
    nodejs
    gcc
    prettierd
    playerctl
    pamixer
    pulseaudio
    binutils
    libarchive
    man-pages
    glibcInfo
    # Currently broken: eclipse-dfa
    gnome.adwaita-icon-theme
    shared-mime-info
    element-desktop
    gnome-network-displays
  ];

  # Ports for gnome-network-displays
  networking.firewall.allowedTCPPorts = [7236 7250];
  networking.firewall.allowedUDPPorts = [7236 5353];
  services.avahi.enable = true;

  # Setup syncthing
  syncthing.enable = true;
  syncthing.keySecretName = "syncthing-desktop-key";
  syncthing.certSecretName = "syncthing-desktop-cert";

  # Setup audio
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };

  # Installing Fonts
  fonts.packages = with pkgs; [
    (nerdfonts.override {fonts = ["FiraCode"];})
    ipafont
  ];

  # Configure bluetooth
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = false;
  };

  programs.ssh = {
    startAgent = true;
  };

  services.openssh.enable = true;

  # Set Hostname
  networking.hostName = "nixos-desktop";

  # Nvidia Stuff
  hardware.nvidia = {
    powerManagement.enable = true;
    modesetting.enable = true;
  };
  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
  };

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
