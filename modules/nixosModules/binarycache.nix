{...}: {
  flake.nixosModules.binarycache = {
    pkgs,
    config,
    lib,
    ...
  }: {
    options.binarycache.enable = lib.mkEnableOption "Enable binarycache";

    config = lib.mkIf config.binarycache.enable {
    services.nix-serve = {
      enable = true;
      bindAddress = "127.0.0.1";
      port = 43192;
      secretKeyFile = "/root/cache-priv-key.pem";
    };

    systemd.timers."nixos-builds" = {
      timerConfig = {
        OnCalendar = "*-*-* 06:00:00";
        Unit = ["nixos-builds.service"];
      };
      wantedBy = ["timers.target"];
    };

    systemd.services."nixos-builds" = {
      serviceConfig = {
        Type = "simple";
        User = "felix";
        Group = "users";
      };
      path = with pkgs; [
        coreutils
        gnutar
        xz.bin
        gzip
        gitMinimal
        config.nix.package.out
        config.programs.ssh.package
      ];
      script = ''
        eval `${config.programs.ssh.package}/bin/ssh-agent`
        ${config.programs.ssh.package}/bin/ssh-add /home/felix/.ssh/id_ed25519
        ${config.nix.package.out}/bin/nix-store --add-fixed sha256 /home/felix/Wonderdraft-1.1.8.2-b-Linux64.zip
        cd /home/felix/nixos-clients
        ${pkgs.gitMinimal}/bin/git pull
        ${config.system.build.nixos-rebuild}/bin/nixos-rebuild build --flake .#nixos-desktop
        ${config.system.build.nixos-rebuild}/bin/nixos-rebuild build --flake .#nixos-laptop
        ${config.nix.package.out}/bin/nix develop .#python
      '';
    };

    services.traefik.dynamicConfigOptions = {
      http = {
        services.binarycacheService.loadBalancer.servers = [
          {
            url = "http://127.0.0.1:43192";
          }
        ];
        routers.binarycacheRouter = {
          entryPoints = ["websecure"];
          rule = "Host(`binarycache.fschwickerath.de`)";
          service = "binarycacheService";
          tls.certResolver = "resolver";
        };
      };
    };
    };
  };
}
