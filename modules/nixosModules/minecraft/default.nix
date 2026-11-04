{...}: {
  flake.nixosModules.minecraft = {
    inputs,
    config,
    pkgs,
    lib,
    ...
  }: let
    inherit (inputs.nix-minecraft.lib) collectFiles;
    inherit (lib) mapAttrs' nameValuePair;
    collectFilesAt = path: subdir: prefix: mapAttrs' (n: nameValuePair "${prefix}${subdir}/${n}") (collectFiles "${path}/${subdir}");
    modpack = pkgs.fetchPackwizModpack {
      src = ./modpack;
      side = "both";
      packHash = "sha256-l84nEL/vGjJC20Mf6ETjkHBwiuVSq/yHUAifyUn+Bz4=";
    };
  in {
    options.minecraft.enable = lib.mkEnableOption "Enable minecraft";

    config = lib.mkIf config.minecraft.enable {
      services.minecraft-servers = {
        enable = true;
        eula = true;
        openFirewall = true;
        servers.fabric = {
          enable = true;
          package = pkgs.neoforgeServers.neoforge-1_21_1-21_1_233;
          symlinks = collectFilesAt modpack "mods" "";
          jvmOpts = "-Xms12G -Xmx12G -XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200 -XX:+UnlockExperimentalVMOptions -XX:+DisableExplicitGC -XX:+AlwaysPreTouch -XX:G1NewSizePercent=30 -XX:G1MaxNewSizePercent=40 -XX:G1HeapRegionSize=8M -XX:G1ReservePercent=20 -XX:G1HeapWastePercent=5 -XX:G1MixedGCCountTarget=4 -XX:InitiatingHeapOccupancyPercent=15 -XX:G1MixedGCLiveThresholdPercent=90 -XX:G1RSetUpdatingPauseTimePercent=5 -XX:SurvivorRatio=32 -XX:+PerfDisableSharedMem -XX:MaxTenuringThreshold=1 -Dusing.aikars.flags=https://mcflags.emc.gs -Daikars.new.flags=true";
        };
      };

      services.borgbackup.jobs.backup.paths = [
        "/srv/minecraft/fabric/world/"
        "/srv/minecraft/fabric/immersive_paintings/"

        "/srv/minecraft/fabric-another/world/"
      ];
    };
  };
}
