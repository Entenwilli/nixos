{
  fetchurl,
  fetchFromGitHub,
  stdenv,
  libarchive,
  python3,
  mecab,
  mecab-ipadic-neologd,
  ...
}:
stdenv.mkDerivation rec {
  name = "yomitan-mecab";
  version = "unstable-${src.rev}-patched";

  src = fetchFromGitHub {
    owner = "yomidevs";
    repo = "yomitan-mecab-installer";
    rev = "4e6532163134ee0471fcf31d94092ff17c870eca";
    hash = "sha256-FpyfphZdE8rmv2aD5ajGxz9fkx6zQU7BUx3prgIpDAw=";
  };

  unidict = fetchurl {
    url = "https://github.com/yomidevs/yomitan-mecab-installer/releases/download/unidic/unidic.zip";
    sha256 = "sha256-yXXin5Mpdub7nQC3TypbixLIJUrjw+Cn8DmyGprCKKY=";
  };

  outputs = [
    "out"
  ];

  runtimeDeps = [
    mecab
  ];

  nativeBuildInputs = [
    python3
  ];

  buildInputs = [
    libarchive
  ];

  buildCommand = ''
    # Copy script to output
    mkdir -p "$out/bin"
    cp $src/mecab.py $out/bin/mecab.py
    patchShebangs $out/bin/mecab.py

    # Copy dictionaries
    mkdir -p "$out/bin/data"
    bsdtar -xf $unidict -C $out/bin/data/

    mkdir -p "$out/bin/data/ipadic-neologd"
    cp -r ${mecab-ipadic-neologd}/* "$out/bin/data/ipadic-neologd/"

    cp $src/mecabrc $out/bin/mecabrc

    # Create native messaging hosts
    mkdir -p "$out/lib/mozilla/native-messaging-hosts"
    substituteAll "${./firefox-native-messaging-hosts.json}" "$out/lib/mozilla/native-messaging-hosts/yomitan_mecab.json"
  '';
}
