{
  lib,
  requireFile,
  stdenv,
  makeDesktopItem,
  makeWrapper,
  libarchive,
  libX11,
  libxcursor,
  libxinerama,
  libxrandr,
  libpulseaudio,
  libxi,
  libGL,
  alsa-lib,
  ...
}:
stdenv.mkDerivation rec {
  name = "wonderdraft";
  version = "1.1.8.2";
  desktopItem = makeDesktopItem {
    name = "Wonderdraft";
    exec = "wonderdraft";
    icon = "wonderdraft";
    comment = "Wonderdraft Map Tool";
    desktopName = "Wonderdraft";
  };

  src = requireFile {
    name = "Wonderdraft-${version}-b-Linux64.zip";
    url = "https://humblebundle.com/";
    hash = "sha256-Eo2VTZSAM28Pf4zOetN56WbrkTXW8Wwrs/99e87q6MM=";
  };

  nativeBuildInputs = [makeWrapper];
  buildInputs = [
    libarchive
    libX11
    libxcursor
    libxinerama
    libxrandr
    libpulseaudio
    libxi
    libGL
    alsa-lib
  ];

  buildCommand = ''
    # Extract download
    mkdir -p $out/Wonderdraft
    bsdtar -xf $src -C $out/Wonderdraft/

    # Patch binaries
    chmod +x $out/Wonderdraft/Wonderdraft.x86_64
    interpreter="$(cat $NIX_BINTOOLS/nix-support/dynamic-linker)"
    patchelf \
      --set-interpreter $interpreter \
      --set-rpath ${lib.makeLibraryPath [libX11 libxcursor libxinerama libxrandr libpulseaudio libxi libGL alsa-lib]} \
      $out/Wonderdraft/Wonderdraft.x86_64

    # Create wrapper script
    makeWrapper $out/Wonderdraft/Wonderdraft.x86_64 $out/bin/wonderdraft

    # Create desktop item
    mkdir -p $out/share/applications
    cp ${desktopItem}/share/applications/* $out/share/applications
    mkdir -p $out/share/pixmaps
    ln -s $out/Wonderdraft/Wonderdraft.png $out/share/pixmaps/Wonderdraft.png
  '';
}
