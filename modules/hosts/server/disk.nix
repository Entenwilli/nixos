{...}: {
  flake.nixosModules.server-disk = {pkgs, ...}: {
    environment.etc."lvm/lvm.conf".text = "global/lvresize_fs_helper_executable = ${pkgs.lvm2.scripts}/lib/libexec/lvresize_fs_helper";

    boot.swraid.enable = true;

    boot.swraid.mdadmConf = "PROGRAM ${pkgs.coreutils}/bin/true";

    disko.devices = {
      disk = {
        one = {
          type = "disk";
          device = "/dev/sda";
          content = {
            type = "gpt";
            partitions = {
              boot = {
                name = "boot";
                size = "1M";
                type = "EF02";
              };
              esp = {
                size = "500M";
                type = "EF00";
                content = {
                  type = "mdraid";
                  name = "boot";
                };
              };
              primary = {
                size = "100%";
                content = {
                  type = "lvm_pv";
                  vg = "pool";
                };
              };
            };
          };
        };
        two = {
          type = "disk";
          device = "/dev/sdb";
          content = {
            type = "gpt";
            partitions = {
              boot = {
                name = "boot";
                size = "1M";
                type = "EF02"; # for grub MBR
              };

              esp = {
                size = "500M";
                type = "EF00";
                content = {
                  type = "mdraid";
                  name = "boot";
                };
              };

              primary = {
                size = "100%";
                content = {
                  type = "lvm_pv";
                  vg = "pool";
                };
              };
            };
          };
        };
      };
      mdadm = {
        boot = {
          type = "mdadm";
          level = 1;
          metadata = "1.0";
          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot";
            mountOptions = ["umask=0077"];
          };
        };
      };
      lvm_vg = {
        pool = {
          type = "lvm_vg";
          lvs = {
            root = {
              size = "100%";
              content = {
                type = "filesystem";
                format = "btrfs";
                mountpoint = "/";
                mountOptions = [
                  "defaults"
                ];
              };
            };
            store = {
              size = "100G";
              content = {
                type = "filesystem";
                format = "btrfs";
                mountpoint = "/nix/store";
                mountOptions = [
                  "defaults"
                ];
              };
            };
          };
        };
      };
    };
  };
}
