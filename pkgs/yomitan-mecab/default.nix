{
  fetchFromGitHub,
  stdenv,
  python3,
  mecab,
  ...
}:
stdenv.mkDerivation rec {
  name = "yomitan-mecab";
  version = "unstable-${src.rev}";

  src = fetchFromGitHub {
    owner = "yomidevs";
    repo = "yomitan-mecab-installer";
    rev = "4e6532163134ee0471fcf31d94092ff17c870eca";
    hash = "sha256-FpyfphZdE8rmv2aD5ajGxz9fkx6zQU7BUx3prgIpDAw=";
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

  buildCommand = ''
    # Copy script to output
    mkdir -p "$out/bin"
    cp $src/mecab.py $out/bin/mecab.py
    patchShebangs $out/bin/mecab.py

    cp $src/mecabrc $out/bin/mecabrc

    # Create native messaging hosts
    mkdir -p "$out/lib/mozilla/native-messaging-hosts"
    substituteAll "${./firefox-native-messaging-hosts.json}" "$out/lib/mozilla/native-messaging-hosts/yomitan_mecab.json"
  '';
}
