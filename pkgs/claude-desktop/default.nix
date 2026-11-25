{
  lib,
  stdenv,
  fetchurl,
  dpkg,
  autoPatchelfHook,
  wrapGAppsHook3,
  makeWrapper,
  alsa-lib,
  at-spi2-core,
  cairo,
  cups,
  dbus,
  expat,
  fontconfig,
  freetype,
  gdk-pixbuf,
  glib,
  gtk3,
  libcap_ng,
  libgbm,
  libseccomp,
  libxcb,
  libxkbcommon,
  libxcomposite,
  libxdamage,
  libxext,
  libxfixes,
  libxrandr,
  libx11,
  nspr,
  nss,
  pango,
  pipewire,
  systemd,
  xdg-utils,
}:
stdenv.mkDerivation rec {
  pname = "claude-desktop";
  version = "6.28899.6";

  src = fetchurl {
    url = "https://downloads.claude.ai/claude-desktop/apt/stable/pool/main/c/claude-desktop/claude-desktop_${version}_amd64.deb";
    hash = "sha256-fjgWAdhlcBSWQ9Uum4nCZXWrEvp4iqQf/dTMpbBjjPg=";
  };

  nativeBuildInputs = [
    dpkg
    autoPatchelfHook
    wrapGAppsHook3
    makeWrapper
  ];

  buildInputs = [
    alsa-lib
    at-spi2-core
    cairo
    cups
    dbus
    expat
    fontconfig
    freetype
    gdk-pixbuf
    glib
    gtk3
    libcap_ng
    libgbm
    libseccomp
    libxcb
    libxkbcommon
    libxcomposite
    libxdamage
    libxext
    libxfixes
    libxrandr
    libx11
    nspr
    nss
    pango
    pipewire
    systemd
    stdenv.cc.cc
  ];

  dontWrapGApps = true;
  dontUnpack = true;
  dontBuild = true;
  dontConfigure = true;

  installPhase = ''
    runHook preInstall

    dpkg --fsys-tarfile $src | tar --extract

    mkdir -p $out
    cp -r usr/lib $out/lib
    cp -r usr/share $out/share
    rm -rf $out/share/lintian $out/share/doc

    mkdir -p $out/bin
    makeWrapper $out/lib/claude-desktop/claude-desktop $out/bin/claude-desktop \
      "''${gappsWrapperArgs[@]}" \
      --set CHROME_DEVEL_SANDBOX "$out/lib/claude-desktop/chrome-sandbox" \
      --suffix PATH : ${lib.makeBinPath [xdg-utils]} \
      --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations}}"

    install -Dm644 $out/lib/claude-desktop/resources/linux-mime/com.anthropic.Claude.xml \
      $out/share/mime/packages/com.anthropic.Claude.xml

    runHook postInstall
  '';

  meta = {
    description = "Desktop client for Claude, Anthropic's AI assistant";
    homepage = "https://claude.ai/download";
    license = lib.licenses.unfree;
    sourceProvenance = with lib.sourceTypes; [binaryNativeCode];
    platforms = ["x86_64-linux"];
    mainProgram = "claude-desktop";
  };
}
