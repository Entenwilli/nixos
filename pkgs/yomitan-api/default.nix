{
  applyPatches,
  fetchFromGitHub,
  stdenv,
  python3,
  ...
}:
stdenv.mkDerivation rec {
  name = "yomitan-api";
  version = "unstable-${src.rev}-patched";

  src = applyPatches {
    src = fetchFromGitHub {
      owner = "yomidevs";
      repo = "yomitan-api";
      rev = "d6a79d184062a048549fa8e82e3a880e2c2783e7";
      hash = "sha256-Xi4APBmsE8lU+BT13KvnaSeHxXzrz/2eMHmNHUiB7GE=";
    };
    patches = [./state-dir.patch];
  };

  outputs = [
    "out"
  ];

  nativeBuildInputs = [
    python3
  ];

  buildCommand = ''
    # Copy script to output
    mkdir -p "$out/bin"
    cp $src/yomitan_api.py $out/bin/yomitan_api.py
    patchShebangs $out/bin/yomitan_api.py

    # Create native messaging hosts
    mkdir -p "$out/lib/mozilla/native-messaging-hosts"
    substituteAll "${./firefox-native-messaging-hosts.json}" "$out/lib/mozilla/native-messaging-hosts/yomitan_api.json"
  '';
}
