{
  lib,
  stdenv,
  makeDesktopItem,
  freetype,
  fontconfig,
  libarchive,
  libX11,
  libXrender,
  perl,
  zlib,
  jdk17,
  glib,
  glib-networking,
  gtk3,
  libXtst,
  libsecret,
  gsettings-desktop-schemas,
  webkitgtk,
  makeWrapper,
  fetchurl,
  ...
}:
stdenv.mkDerivation rec {
  name = "eclipse-dfa";
  version = "3.0.0-nightly-07.08.24";
  desktopItem = makeDesktopItem {
    name = "DataFlowAnalysis";
    exec = "env GDK_BACKEND=\"x11\" WEBKIT_DISABLE_COMPOSITING_MODE=1 WEBKIT_DISABLE_DMABUF_RENDERER=1 DataFlowAnalysisBench";
    icon = "DataFlowAnalysisBench";
    comment = "Integrated Development Environment";
    desktopName = "DataFlowAnalysis";
    genericName = "Integrated Development Environment";
    categories = ["Development"];
  };

  src = fetchurl {
    url = "https://updatesite.palladio-simulator.com/DataFlowAnalysis/product/nightly/DataFlowAnalysis.linux.gtk.x86_64.zip";
    hash = "sha256-ZGaKlgWPXnkAJYPHG9abKIVxScmR20iVx0vh7hDS88w=";
  };

  nativeBuildInputs = [makeWrapper perl];
  buildInputs = [
    fontconfig
    freetype
    glib
    gsettings-desktop-schemas
    gtk3
    jdk17
    libarchive
    libX11
    libXrender
    libXtst
    libsecret
    zlib
    webkitgtk
  ];

  buildCommand = ''
    # Extract download
    mkdir -p $out/DataFlowAnalysisBench
    bsdtar -xf $src -C $out/DataFlowAnalysisBench/

    # Patch binaries
    interpreter="$(cat $NIX_BINTOOLS/nix-support/dynamic-linker)"
      libCairo=$out/DataFlowAnalysisBench/libcairo-swt.so
      patchelf --set-interpreter $interpreter $out/DataFlowAnalysisBench/DataFlowAnalysisBench
      [ -f $libCairo ] && patchelf --set-rpath ${lib.makeLibraryPath [freetype fontconfig libX11 libXrender zlib]} $libCairo

    # Create wrapper script
    productId=$(sed 's/id=//; t; d' $out/DataFlowAnalysisBench/.eclipseproduct)
    makeWrapper $out/DataFlowAnalysisBench/DataFlowAnalysisBench $out/bin/DataFlowAnalysisBench \
        --prefix PATH : ${jdk17}/bin \
        --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [glib gtk3 libXtst libsecret webkitgtk]} \
        --prefix GIO_EXTRA_MODULES : "${glib-networking}/lib/gio/modules" \
        --prefix XDG_DATA_DIRS : "$GSETTINGS_SCHEMAS_PATH" \
        --add-flags "-configuration \$HOME/.eclipse/''${productId}_${version}/configuration"

    # Create desktop item
    mkdir -p $out/share/applications
    cp ${desktopItem}/share/applications/* $out/share/applications
    mkdir -p $out/share/pixmaps
    ln -s $out/DataFlowAnalysisBench/icon.xpm $out/share/pixmaps/DataFlowAnalysisBench.xpm

    # ensure eclipse.ini does not try to use a justj jvm, as those aren't compatible with nix
    perl -i -p0e 's|-vm\nplugins/org.eclipse.justj.*/jre/bin.*\n||' $out/DataFlowAnalysisBench/DataFlowAnalysisBench.ini
  '';
}
