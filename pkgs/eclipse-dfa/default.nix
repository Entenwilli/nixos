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
  jdk21,
  glib,
  glib-networking,
  gtk3,
  libXtst,
  libsecret,
  gsettings-desktop-schemas,
  webkitgtk_4_1,
  makeWrapper,
  fetchurl,
  writeShellApplication,
  curl,
  gnused,
  jq,
  git,
  nix,
  ...
}: let
  url = "https://updatesite.palladio-simulator.com/DataFlowAnalysis/product/branches/maven-build";
  artifactUrl = "${url}/DataFlowAnalysis.linux.gtk.x86_64.tar.gz";
in
  stdenv.mkDerivation rec {
    name = "eclipse-dfa";
    version = "5.1.0-nightly-19.11.2026";
    desktopItem = makeDesktopItem {
      name = "DataFlowAnalysis";
      exec = "env WEBKIT_DISABLE_COMPOSITING_MODE=1 WEBKIT_DISABLE_DMABUF_RENDERER=1 DataFlowAnalysisBench";
      icon = "DataFlowAnalysisBench";
      comment = "Integrated Development Environment";
      desktopName = "DataFlowAnalysis";
      genericName = "Integrated Development Environment";
      categories = ["Development"];
    };

    src = fetchurl {
      url = artifactUrl;
      hash = "sha256-m9SH+kdhf4mgexWo/0xULd9SN/1Ay2LfDgKuYZizXWc=";
    };

    nativeBuildInputs = [makeWrapper perl];
    buildInputs = [
      fontconfig
      freetype
      glib
      gsettings-desktop-schemas
      gtk3
      jdk21
      libarchive
      libX11
      libXrender
      libXtst
      libsecret
      zlib
      webkitgtk_4_1
    ];

    buildCommand = ''
      # Extract download
      mkdir -p $out/DataFlowAnalysisBench
      bsdtar -xf $src -C $out/DataFlowAnalysisBench/

      # Rename jars to remove date of build (only name and version should be in the name)
      cp -r $out/DataFlowAnalysisBench/plugins $out/DataFlowAnalysisBench/plugins-normalized
      for file in $out/DataFlowAnalysisBench/plugins-normalized/*.jar; do
        if [ -e "$file" ]; then
          newname=$(echo "$file" | sed -r 's|(.*)\_([0-9]+\.[0-9]+\.[0-9]+).*$|\1\2.jar|')
          mv "$file" "$newname"
        fi
      done

      # Patch binaries
      interpreter="$(cat $NIX_BINTOOLS/nix-support/dynamic-linker)"
        libCairo=$out/DataFlowAnalysisBench/libcairo-swt.so
        patchelf --set-interpreter $interpreter $out/DataFlowAnalysisBench/DataFlowAnalysisBench
        [ -f $libCairo ] && patchelf --set-rpath ${lib.makeLibraryPath [freetype fontconfig libX11 libXrender zlib]} $libCairo

      # Create wrapper script
      productId=$(sed 's/id=//; t; d' $out/DataFlowAnalysisBench/.eclipseproduct)
      makeWrapper $out/DataFlowAnalysisBench/DataFlowAnalysisBench $out/bin/DataFlowAnalysisBench \
          --prefix PATH : ${jdk21}/bin \
          --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [glib gtk3 libXtst libsecret webkitgtk_4_1]} \
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

    passthru.updateScript = writeShellApplication {
      name = "update-eclipse-dfa";
      runtimeInputs = [curl gnused jq git nix];
      text = ''
        file="$(git rev-parse --show-toplevel)/pkgs/eclipse-dfa/default.nix"

        # The build server always serves the latest nightly at a fixed URL, so
        # the actual build date comes from the Last-Modified response header.
        last_modified=$(curl -sIL "${artifactUrl}" | tr -d '\r' | sed -n 's/^[Ll]ast-[Mm]odified: *//p' | tail -n1)
        new_date=$(date -u -d "$last_modified" +%d.%m.%Y)
        new_version="5.1.0-nightly-$new_date"

        new_hash=$(nix store prefetch-file --json "${artifactUrl}" | jq -r .hash)

        sed -i \
          -e "s|version = \"[^\"]*\";|version = \"$new_version\";|" \
          -e "s|hash = \"[^\"]*\";|hash = \"$new_hash\";|" \
          "$file"

        echo "eclipse-dfa: updated to $new_version ($new_hash)"
      '';
    };
  }
