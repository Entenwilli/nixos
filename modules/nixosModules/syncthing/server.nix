{...}: {
  flake.nixosModules.server-syncthing = {
    config,
    lib,
    ...
  }: {
    config = lib.mkIf (config.syncthing.enable && config.hostRole == "server") {
      sops.secrets."syncthing-gui-password" = {
        owner = "syncthing";
        restartUnits = ["syncthing-init.service"];
      };

      syncthing = {
        user = "syncthing";
        group = "syncthing";
        keyFile = "/root/syncthing-key.pem";
        certFile = "/root/syncthing-cert.pem";
        guiPasswordFile = config.sops.secrets."syncthing-gui-password".path;
        runsInGraphicalSession = false;
        exposeViaTraefik = true;
        enableBorgBackup = true;

        devices = {
          "christine-phone" = {id = "DPBT573-PI2BAQU-AWVLOEN-ZAHVQYW-VTE5ONJ-VFUCDEP-OMWJAV3-6I74ZAZ";};
          "christine-tablet" = {id = "7UTO2XQ-IZZBCXY-BSOSDVG-SB346A5-XMOKL5J-KM6W4TB-3MXAWCB-Z2WQGAF";};
          "thomas-phone" = {id = "OJ2JJ4L-FTKGGJ3-F4HIL4Z-7GEGBYB-J2CROC3-7Q3GTXG-HYNH3LT-QKOV5AS";};
          "thomas-desktop" = {id = "D5WIEH4-EB4KJW2-OYYVILC-ULCUS7O-LAXKHMG-RERWEYF-HCWIEZU-WIOL7AJ";};
          "felix-phone" = {id = "NOGRX5K-UGF5USB-E6R54VA-4AIVMGQ-6GSNJMX-7G4ATT2-UZ23Z4D-2OWW3QG";};
          "felix-laptop" = {id = "LNJ37Z6-XJ5IZTK-OTM27G5-V5LJXUY-NXFUDIL-VZJQGOY-HPZCTZU-SSVSSQ3";};
          "felix-desktop" = {id = "6HPI2LL-UJQHJJF-HITCUNM-RY44X72-3YN3MMH-VH6GAJH-SGXVSN6-PWRSTAG";};
        };
        folders = let
          felix-devices = ["felix-phone" "felix-laptop" "felix-desktop"];
          parents-devices = ["christine-phone" "christine-tablet" "thomas-phone" "thomas-desktop"];
        in {
          "Bilder" = {
            path = "/var/lib/syncthing/Bilder/";
            id = "Bilder";
            devices = felix-devices;
          };
          "Dokumente" = {
            path = "/var/lib/syncthing/Dokumente/";
            id = "Dokumente";
            devices = felix-devices;
          };
          "General" = {
            path = "/var/lib/syncthing/General/";
            id = "General";
            devices = felix-devices;
          };
          "Musik" = {
            path = "/var/lib/syncthing/Musik/";
            id = "Musik";
            devices = felix-devices;
          };
          "parent-passwords" = {
            path = "/var/lib/syncthing/parent-passwords/";
            id = "m6gty-cl2jf";
            devices = parents-devices;
          };
        };
      };
    };
  };
}
