{
  appimageTools,
  fetchurl,
  steam,
  makeDesktopItem,
}: let
  pname = "ffxiv-teamcraft";
  version = "11.4.25";

  src = fetchurl {
    url = "https://github.com/ffxiv-teamcraft/ffxiv-teamcraft/releases/download/v${version}/FFXIV-Teamcraft.AppImage";
    hash = "sha256-hfQYm11qgoeZjgwGS1gb8+BKLyIAPW2LyH5alJTujus=";
  };

  appimageContents = appimageTools.extract {
    inherit pname version src;
  };
in
  appimageTools.wrapAppImage rec {
    inherit pname version;

    src = appimageContents;

    passthru.src = src;

    extraPkgs = pkgs:
      with pkgs; [
        libunwind
      ];

    extraInstallCommands = ''
      # Create Desktop Items
      mkdir -p $out/share/applications
      cp ${desktopItem}/share/applications/* $out/share/applications

      # Add deucalion binaries
      cp ${appimageContents}/deucalion-bridge/deucalion-bridge.exe \
        $out/bin/deucalion-bridge.exe
      cp ${appimageContents}/deucalion/deucalion.dll \
        $out/bin/deucalion.dll
    '';

    postFixup = let
      steam-run =
        (steam.override {
          extraPkgs = pkgs: [pkgs.libunwind];
          extraProfile = ''
            unset TZ
          '';
        }).run;
    in ''
      substituteInPlace $out/bin/ffxiv-teamcraft \
        --replace-fail 'exec' 'exec ${steam-run}/bin/steam-run'
    '';

    executables = ["ffxiv-teamcraft"];

    desktopItem = makeDesktopItem {
      name = "ffxiv-teamcraft";
      exec = "ffxiv-teamcraft";
      icon = "ffxiv-teamcraft";
      desktopName = "FFXIV Teamcraft";
      categories = ["Game"];
      startupWMClass = "ffxiv-teamcraft";
    };
  }
