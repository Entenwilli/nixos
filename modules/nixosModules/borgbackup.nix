{...}: {
  flake.nixosModules.borgbackup = {
    config,
    pkgs,
    lib,
    ...
  }: {
    options.borgbackup.enable = lib.mkEnableOption "Enable borgbackup";

    config = lib.mkIf config.borgbackup.enable {
    services.borgbackup = {
      jobs.backup = {
        doInit = true;
        repo = "ssh://u543537@u543537.your-storagebox.de:23/./backups/NixOSServer";
        environment = {
          BORG_RSH = "ssh -i /root/id_backup";
        };
        encryption = {
          mode = "repokey-blake2";
          passCommand = "cat /root/borg";
        };
        compression = "auto,lzma";
        startAt = "*-*-* 05:00:00";
        prune.keep = {
          within = "1d";
          daily = 7;
          monthly = -1;
        };
        paths = ["/root" "/home/felix/"];
        extraArgs = ["--debug" "--verbose"];
        preHook = ''
          ${pkgs.systemd}/bin/systemctl stop minecraft-server-fabric.service
          ${pkgs.systemd}/bin/systemctl stop couchdb.service
          ${pkgs.systemd}/bin/systemctl stop docker.service
          ${pkgs.systemd}/bin/systemctl stop filebrowser.service
          ${pkgs.systemd}/bin/systemctl stop ntfy-sh.service
          ${pkgs.systemd}/bin/systemctl stop paperless-consumer.service
          ${pkgs.systemd}/bin/systemctl stop paperless-scheduler.service
          ${pkgs.systemd}/bin/systemctl stop paperless-task-queue.service
          ${pkgs.systemd}/bin/systemctl stop paperless-web.service
          ${pkgs.systemd}/bin/systemctl stop postgresql.service
          ${pkgs.systemd}/bin/systemctl stop redis-paperless.service
          ${pkgs.systemd}/bin/systemctl stop syncthing.service
          ${pkgs.systemd}/bin/systemctl stop shiori.service
          ${pkgs.systemd}/bin/systemctl stop traefik.service
          ${pkgs.systemd}/bin/systemctl stop uptime-kuma.service
        '';
        postPrune = ''
          ${pkgs.systemd}/bin/systemctl start minecraft-server-fabric.service
          ${pkgs.systemd}/bin/systemctl start couchdb.service
          ${pkgs.systemd}/bin/systemctl start docker.service
          ${pkgs.systemd}/bin/systemctl start filebrowser.service
          ${pkgs.systemd}/bin/systemctl start ntfy-sh.service
          ${pkgs.systemd}/bin/systemctl start paperless-consumer.service
          ${pkgs.systemd}/bin/systemctl start paperless-scheduler.service
          ${pkgs.systemd}/bin/systemctl start paperless-task-queue.service
          ${pkgs.systemd}/bin/systemctl start paperless-web.service
          ${pkgs.systemd}/bin/systemctl start postgresql.service
          ${pkgs.systemd}/bin/systemctl start redis-paperless.service
          ${pkgs.systemd}/bin/systemctl start syncthing.service
          ${pkgs.systemd}/bin/systemctl start shiori.service
          ${pkgs.systemd}/bin/systemctl start traefik.service
          ${pkgs.systemd}/bin/systemctl start uptime-kuma.service
        '';
      };
    };
    };
  };
}
