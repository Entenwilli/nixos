{
  appimageTools,
  fetchurl,
}: let
  pname = "ffxiv-teamcraft";
  version = "11.4.25";

  src = fetchurl {
    url = "https://github.com/ffxiv-teamcraft/ffxiv-teamcraft/releases/download/v${version}/FFXIV-Teamcraft.AppImage";
    hash = "sha256-hfQYm11qgoeZjgwGS1gb8+BKLyIAPW2LyH5alJTujus=";
  };
in
  appimageTools.wrapType2 {
    inherit pname version src;
    extraPkgs = pkgs:
      with pkgs; [
        libunwind
      ];
  }
