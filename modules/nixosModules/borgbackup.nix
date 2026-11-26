{...}: {
  flake.nixosModules.borgbackup = {
    config,
    pkgs,
    lib,
    ...
  }: {
    options.borgbackup.enable = lib.mkEnableOption "Enable borgbackup";

    options.borgbackup.sourcePaths = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = ''
        Live filesystem paths to include in the borg backup. Paths are
        automatically remapped onto the read-only pre-backup btrfs snapshot,
        so services do not need to be stopped for a consistent backup.
      '';
    };

    config = lib.mkIf config.borgbackup.enable {
      borgbackup.sourcePaths = ["/root" "/home/felix/"];

      services.borgbackup.jobs.backup = {
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
        paths = map (p: "/.snapshots/borg-pre" + p) config.borgbackup.sourcePaths;
        extraArgs = ["--debug" "--verbose"];
        preHook = ''
          if [ -d /.snapshots/borg-pre ]; then
            ${pkgs.btrfs-progs}/bin/btrfs subvolume delete /.snapshots/borg-pre
          fi
          mkdir -p /.snapshots
          ${pkgs.btrfs-progs}/bin/btrfs subvolume snapshot -r / /.snapshots/borg-pre
        '';
        postHook = ''
          if [ -d /.snapshots/borg-pre ]; then
            ${pkgs.btrfs-progs}/bin/btrfs subvolume delete /.snapshots/borg-pre
          fi
        '';
      };
    };
  };
}
