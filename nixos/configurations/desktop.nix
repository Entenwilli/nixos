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

  sops.secrets."github-token-desktop" = {
    owner = "felix";
  };
  nix.extraOptions = ''
    !include ${config.sops.secrets."github-token-desktop".path}
  '';

  # Enable nixos-helper
  nixos-helper.enable = true;

  services.dbus = {
    enable = true;
    packages = with pkgs; [dunst];
  };

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

  # Boot splash screen
  boot.consoleLogLevel = 0;
  boot.initrd.verbose = false;
  boot.plymouth = {
    enable = true;
    themePackages = with pkgs; [
      (catppuccin-plymouth.override {
        variant = "mocha";
      })
    ];
    theme = "catppuccin-mocha";
  };

  # Enable display manager
  services.xserver.enable = true;
  services.displayManager = {
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
  documentation.man.generateCaches = false;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.felix = {
    hashedPassword = "$y$j9T$hHy3Jnr8hvdSqLRV3z2760$G.Hr/DOnqhA6c2IfcAcPDGByVm8EOrtvKTnrGKYPodB";
    uid = 1000;
    isNormalUser = true;
    shell = pkgs.fish;
    extraGroups = ["wheel" "audio" "network" "networkmanager"]; # Enable ‘sudo’ for the user.
    packages = with pkgs; [
      eza
      firefox
    ];
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    age
    sops
    git
    fastfetch
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
    eclipse-dfa
    adwaita-icon-theme
    shared-mime-info
    element-desktop
    gnome-network-displays
  ];

  # Create Data Flow Analysis symlink
  system.activationScripts = {
    eclipse-dfa.text = "ln -sfn ${pkgs.eclipse-dfa}/DataFlowAnalysisBench/plugins /etc/eclipse-dfa";
  };

  # Enable own neovim distribution
  programs.entenvim.enable = true;

  # Ports for gnome-network-displays
  networking.firewall.allowedTCPPorts = [7236 7250];
  networking.firewall.allowedUDPPorts = [7236 5353];
  services.avahi.enable = true;

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

  # Setup audio
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };

  # Installing Fonts
  fonts.packages = with pkgs; [
    unstable.nerd-fonts.fira-code
    unstable.nerd-fonts.hack
    unstable.nerd-fonts.jetbrains-mono
    jetbrains-mono
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
