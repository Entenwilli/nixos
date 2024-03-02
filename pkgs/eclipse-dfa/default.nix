{ lib, stdenv, makeDesktopItem, freetype, fontconfig, libX11, libXrender
, zlib, jdk, glib, glib-networking, gtk3, libXtst, libsecret, gsettings-desktop-schemas, webkitgtk
, makeWrapper, libarchive, fetchurl, ... }:

stdenv.mkDerivation rec {
  name = "eclipse-dfa";
  desktopItem = makeDesktopItem {
    name = "DataFlowAnalysis";
    exec = "eclipse";
    icon = "eclipse";
    comment = "Integrated Development Environment";
    desktopName = "DataFlowAnalysis";
    genericName = "Integrated Development Environment";
    categories = [ "Development" ];
  }; 

  src = 
    fetchurl {
      url = "https://github.com/DataFlowAnalysis/DataFlowAnalysis/releases/download/v1.0.0/DataFlowAnalysis.linux.gtk.x86_64.zip";
      hash = "sha256-JRXVuck5JCr6ox4/siK02mMBQgsGbS5mQjX2NiWsefw=";
    };

 nativeBuildInputs = [ makeWrapper ];
  buildInputs = [
    fontconfig freetype glib gsettings-desktop-schemas gtk3 jdk libX11
    libXrender libXtst libsecret zlib libarchive
  ] ++ lib.optional (webkitgtk != null) webkitgtk;

  buildCommand = ''
  # Extract download
  mkdir -p $out/eclipse
  bsdtar -xf $src -C $out/eclipse

  # Patch binaries
  interpreter="$(cat $NIX_BINTOOLS/nix-support/dynamic-linker)"
    libCairo=$out/eclipse/libcairo-swt.so
    patchelf --set-interpreter $interpreter $out/eclipse/eclipse
    [ -f $libCairo ] && patchelf --set-rpath ${lib.makeLibraryPath [ freetype fontconfig libX11 libXrender zlib ]} $libCairo

  # Create wrapper script
  makeWrapper $out/eclipse/eclipse $out/bin/eclipse \
      --prefix PATH : ${jdk}/bin \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath ([ glib gtk3 libXtst libsecret ] ++ lib.optional (webkitgtk != null) webkitgtk)} \
      --prefix GIO_EXTRA_MODULES : "${glib-networking}/lib/gio/modules" \
      --prefix XDG_DATA_DIRS : "$GSETTINGS_SCHEMAS_PATH"

  # Create desktop item
  mkdir -p $out/share/applications
  cp ${desktopItem}/share/applications/* $out/share/applications 
  '';
}
