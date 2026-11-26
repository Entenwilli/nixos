{...}: {
  flake.nixosModules.minecraft = {
    config,
    pkgs,
    lib,
    ...
  }: let
    modpackSrc = ./modpack;
    index = fromTOML (builtins.readFile (modpackSrc + "/index.toml"));
    modMetaFiles = builtins.filter (f: (f.metafile or false) && lib.hasPrefix "mods/" f.file) index.files;
    modJars = map (f: (fromTOML (builtins.readFile (modpackSrc + "/${f.file}"))).filename) modMetaFiles;
    modpack = pkgs.fetchPackwizModpack {
      src = modpackSrc;
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
          symlinks = lib.listToAttrs (map (jar: lib.nameValuePair "mods/${jar}" "${modpack}/mods/${jar}") modJars);
          jvmOpts = "-Xms12G -Xmx12G -XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200 -XX:+UnlockExperimentalVMOptions -XX:+DisableExplicitGC -XX:+AlwaysPreTouch -XX:G1NewSizePercent=30 -XX:G1MaxNewSizePercent=40 -XX:G1HeapRegionSize=8M -XX:G1ReservePercent=20 -XX:G1HeapWastePercent=5 -XX:G1MixedGCCountTarget=4 -XX:InitiatingHeapOccupancyPercent=15 -XX:G1MixedGCLiveThresholdPercent=90 -XX:G1RSetUpdatingPauseTimePercent=5 -XX:SurvivorRatio=32 -XX:+PerfDisableSharedMem -XX:MaxTenuringThreshold=1 -Dusing.aikars.flags=https://mcflags.emc.gs -Daikars.new.flags=true";
        };
      };

      borgbackup.sourcePaths = [
        "/srv/minecraft/fabric/world/"
        "/srv/minecraft/fabric/immersive_paintings/"

        "/srv/minecraft/fabric-another/world/"
      ];
    };
  };
}
