{
  inputs,
  self,
  ...
}: {
  flake.nixosConfigurations.nixos-server = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    specialArgs = {inherit inputs;};
    modules = [
      inputs.disko.nixosModules.disko
      inputs.sops-nix.nixosModules.sops
      inputs.nix-minecraft.nixosModules.minecraft-servers
      self.nixosModules.server
    ];
  };

  flake.nixosModules.server = {
    config,
    pkgs,
    lib,
    inputs,
    ...
  }: {
    imports = [
      self.nixosModules.server-hardware
      self.nixosModules.server-disk
      self.nixosModules.server-network
      self.nixosModules.host-role
      self.nixosModules.adventurelog
      self.nixosModules.shiori
      self.nixosModules.glance
      self.nixosModules.fileshare
      self.nixosModules.solidtime
      self.nixosModules.ntfy
      self.nixosModules.obsidian-sync
      self.nixosModules.paperless
      self.nixosModules.syncthing
      self.nixosModules.server-syncthing
      self.nixosModules.traefik
      self.nixosModules.uptime
      self.nixosModules.borgbackup
      self.nixosModules.binarycache
      self.nixosModules.homeassistant
      self.nixosModules.minecraft
      self.nixosModules.grafana
      self.nixosModules.prometheus
    ];

    nixpkgs.overlays = [
      self.overlays.additions
      self.overlays.server-fixes
      inputs.nix-minecraft.overlay
    ];

    hostRole = "server";

    adventurelog.enable = true;
    shiori.enable = true;
    glance.enable = true;
    fileshare.enable = true;
    solidtime.enable = true;
    ntfy.enable = true;
    obsidian-sync.enable = true;
    paperless.enable = true;
    syncthing.enable = true;
    traefik.enable = true;
    uptime.enable = true;
    borgbackup.enable = true;
    binarycache.enable = true;
    homeassistant.enable = true;
    grafana.enable = true;
    prometheus.enable = true;
    minecraft.enable = true;

    programs.ssh.startAgent = true;
    sops.defaultSopsFile = ../../secrets/nixos-server.yaml;
    sops.defaultSopsFormat = "yaml";

    sops.age.sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];

    nix.settings.max-jobs = 4;

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
    nixpkgs.config.allowUnfreePredicate = pkg:
      builtins.elem (lib.getName pkg) [
        "minecraft-server"
        "teamspeak-server"
        "neoforge"
      ];

    boot.loader.grub = {
      efiSupport = true;
      efiInstallAsRemovable = true;
    };

    users.users.felix = {
      hashedPassword = "$y$j9T$hHy3Jnr8hvdSqLRV3z2760$G.Hr/DOnqhA6c2IfcAcPDGByVm8EOrtvKTnrGKYPodB";
      uid = 1000;
      isNormalUser = true;
      shell = pkgs.fish;
      extraGroups = ["wheel"];
      packages = with pkgs; [
        eza
        lazygit
        fish
        btop
        libgcc
      ];
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIE3jshF9A5qT7efeZBHTzRwWQULeIQBPdgOgh1pbFd0k felix@fschwickerath.de"
      ];
    };

    programs.fish.enable = true;
    users.defaultUserShell = pkgs.fish;
    documentation.man.cache.enable = false;

    services.openssh.enable = true;

    environment.systemPackages = with pkgs; [
      packwiz
      tmux
      neovim
      git
      curl
      inputs.entenvim.packages.${pkgs.stdenv.hostPlatform.system}.default
    ];

    programs.nh = {
      enable = true;
      clean.enable = true;
    };

    users.users.root.openssh.authorizedKeys.keys = ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIE3jshF9A5qT7efeZBHTzRwWQULeIQBPdgOgh1pbFd0k felix@fschwickerath.de"];

    networking.firewall.allowedTCPPorts = [22 80 443];
    time.timeZone = "Europe/Berlin";

    system.autoUpgrade = {
      enable = true;
      flake = "github:Entenwilli/nixos#nixos-server";
      dates = "03:30";
      randomizedDelaySec = "0";
      allowReboot = false;
    };

    systemd.timers.restart = {
      timerConfig = {
        OnCalendar = "*-*-* 04:00:00";
        Unit = ["restart.service"];
      };
      wantedBy = ["timers.target"];
    };

    systemd.services.restart = {
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.systemd}/bin/systemctl reboot";
      };
    };

    system.stateVersion = "25.05";
  };
}
