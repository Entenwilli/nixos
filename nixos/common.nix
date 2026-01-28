{
  inputs,
  lib,
  config,
  pkgs,
  outputs,
  ...
}: {
  imports = [
    ./gaming.nix
  ];

  # Configure nix package manager
  nixpkgs = {
    overlays = [
      outputs.overlays.additions
      outputs.overlays.modifications
      outputs.overlays.unstable-packages
      inputs.nur.overlays.default
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

  # Flake caching
  nix.settings = {
    substituters = [
      "https://hyprland.cachix.org"
      "https://pwndbg.cachix.org"
    ];
    trusted-public-keys = [
      "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
      "pwndbg.cachix.org-1:HhtIpP7j73SnuzLgobqqa8LVTng5Qi36sQtNt79cD3k="
    ];
  };

  # Enable nixos-helper
  nixos-helper.enable = true;

  services.udisks2.enable = true;

  programs.java = {
    enable = true;
    package = pkgs.javaPackages.compiler.openjdk17;
  };

  programs.ssh.enableAskPassword = true;
  programs.ssh.askPassword = "${pkgs.seahorse}/libexec/seahorse/ssh-askpass";

  services.dbus = {
    enable = true;
    packages = with pkgs; [dunst];
  };

  # Boot splash screen
  boot.consoleLogLevel = 0;
  boot.kernelParams = ["quiet" "systemd.show_status=auto" "rd.udev.log_level=0"];
  boot.initrd.verbose = false;
  boot.plymouth = {
    enable = true;
    themePackages = with pkgs; [
      (catppuccin-plymouth.override {
        variant = "mocha";
      })
    ];
    logo = "${pkgs.nixos-icons}/share/icons/hicolor/128x128/apps/nix-snowflake-white.png";
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

  # Enable fish
  programs.fish.enable = true;
  users.defaultUserShell = pkgs.fish;
  documentation.man.generateCaches = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.felix = {
    hashedPassword = "$y$j9T$hHy3Jnr8hvdSqLRV3z2760$G.Hr/DOnqhA6c2IfcAcPDGByVm8EOrtvKTnrGKYPodB";
    uid = 1000;
    isNormalUser = true;
    shell = pkgs.fish;
    extraGroups = ["wheel" "audio" "network" "networkmanager" "video" "render" "docker" "gamemode"]; # Enable ‘sudo’ for the user.
    packages = with pkgs; [
      eza
      libva
      ffmpeg
    ];
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    gnome-network-displays
    mesa
    docker
    docker-compose
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
    xdg-user-dirs
    mecab
    qbittorrent
    goldendict-ng
    hunspell
    solidtime-desktop
  ];

  # Create Data Flow Analysis symlink
  system.activationScripts = {
    eclipse-dfa.text = "ln -sfn ${pkgs.eclipse-dfa}/DataFlowAnalysisBench/plugins-normalized /etc/eclipse-dfa";
  };

  # Enable own neovim distribution
  programs.entenvim.enable = true;

  # Ports for gnome-network-displays
  networking.firewall.allowedTCPPorts = [7236 7250];
  networking.firewall.allowedUDPPorts = [7236 5353];
  services.avahi.enable = true;

  # Setup audio
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    wireplumber.enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };

  # Installing Fonts
  fonts.packages = with pkgs; [
    nerd-fonts.fira-code
    nerd-fonts.hack
    nerd-fonts.jetbrains-mono
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

  # Japanese IMEs
  i18n.inputMethod = {
    type = "fcitx5";
    enable = true;
    fcitx5 = {
      waylandFrontend = true;
      addons = with pkgs; [
        fcitx5-gtk
        fcitx5-mozc
        catppuccin-fcitx5
      ];
    };
  };

  programs.gnupg = {
    agent.enable = true;
    agent.pinentryPackage = pkgs.pinentry-rofi;
  };
}
