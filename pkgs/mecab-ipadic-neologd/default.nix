{
  lib,
  stdenv,
  fetchFromGitHub,
  mecab,
  glibc,
  xz,
  patch,
}: let
  neologd = fetchFromGitHub {
    owner = "neologd";
    repo = "mecab-ipadic-neologd";
    rev = "abc61e33d8be3d0ead202e6b1df064c72d5ccf11";
    hash = "sha256-koFon2E+vt/Lr3je7UFEBXhCxWob6KnDY1N6rHmTr5U=";
  };

  # Yomigana (furigana) fixup patches applied, in order, by upstream's
  # libexec/make-mecab-ipadic-neologd.sh (its two commented-out patches,
  # Noun.number and Symbol, are skipped the same way upstream skips them).
  patchFiles = [
    "Noun.csv.20160404.diff"
    "Noun.place.csv.20150609.diff"
    "Verb.csv.20150609.diff"
    "Noun.verbal.csv.20150813.diff"
    "Noun.name.csv.20150905.diff"
    "Noun.adverbal.csv.20160421.diff"
    "Noun.csv.20160421.diff"
    "Noun.name.csv.20160421.diff"
    "Noun.org.csv.20160421.diff"
    "Noun.others.csv.20160421.diff"
    "Noun.place.csv.20160421.diff"
    "Noun.proper.csv.20160421.diff"
    "Noun.verbal.csv.20160421.diff"
    "Prefix.csv.20160421.diff"
    "Suffix.csv.20160421.diff"
    "Noun.proper.csv.20160519.diff"
    "Noun.csv.20160923.diff"
    "Noun.name.csv.20160923.diff"
    "Noun.org.csv.20160923.diff"
    "Noun.place.csv.20160923.diff"
    "Noun.proper.csv.20160923.diff"
    "Noun.verbal.csv.20160923.diff"
    "Noun.name.csv.20161005.diff"
    "Noun.org.csv.20161005.diff"
    "Noun.place.csv.20161005.diff"
    "Noun.proper.csv.20161005.diff"
    "Suffix.csv.20161027.diff"
    "Noun.demonst.csv.20170228.diff"
    "Noun.csv.20170317.diff"
    "Noun.name.csv.20170317.diff"
  ];

  # Word-list seeds merged in when upstream's install script runs with no
  # --ignore_*/--install_* flags. adjective-exp, infreq-datetime and
  # infreq-quantity are opt-in upstream, so they're left out here too.
  seedFiles = [
    "mecab-user-dict-seed.20200910.csv"
    "neologd-adverb-dict-seed.20150623.csv"
    "neologd-interjection-dict-seed.20170216.csv"
    "neologd-common-noun-ortho-variant-dict-seed.20170228.csv"
    "neologd-proper-noun-ortho-variant-dict-seed.20161110.csv"
    "neologd-noun-sahen-conn-ortho-variant-dict-seed.20160323.csv"
    "neologd-adjective-std-dict-seed.20151126.csv"
    "neologd-ill-formed-words-dict-seed.20170127.csv"
  ];
in
  stdenv.mkDerivation {
    pname = "mecab-ipadic-neologd";
    version = "unstable-2020-09-14";

    # Same mecab-ipadic source/rev nixpkgs' own mecab-ipadic derivation
    # (pkgs/by-name/me/mecab/ipadic.nix) builds from.
    src = fetchFromGitHub {
      owner = "taku910";
      repo = "mecab";
      rev = "2fd29256c6d5e1b10211cac838069ee9ede8c77a";
      hash = "sha256-FKRm4bIBhmE4gafg9JeMnpjXbAu4c7l7XIJVbnsRVi8=";
      rootDir = "mecab-ipadic";
    };

    inherit neologd;

    nativeBuildInputs = [mecab glibc.bin xz patch];

    configureFlags = [
      "--with-charset=utf8"
      "--with-dicdir=${placeholder "out"}"
      "--with-mecab-config=${lib.getExe' mecab "mecab-config"}"
    ];

    buildPhase = ''
      runHook preBuild

      # mecab-ipadic's CSV/def resources ship EUC-JP encoded; NEologd's own
      # patches and seed data are UTF-8, so convert before merging them in.
      for f in $(find . -maxdepth 1 \( -name '*.csv' -o -name '*.def' \)); do
        iconv -f EUC-JP -t UTF-8 "$f" | sed -e 's/—/―/g' > "$f.utf8"
        mv "$f.utf8" "$f"
      done

      for p in ${lib.concatStringsSep " " patchFiles}; do
        patch < "$neologd/misc/patch/$p"
      done

      for s in ${lib.concatStringsSep " " seedFiles}; do
        xz -dc "$neologd/seed/$s.xz" > "./$s"
      done
      cp "$neologd/misc/dic/unk.def" .

      "$(mecab-config --libexecdir)/mecab-dict-index" -f UTF8 -t UTF8

      make

      runHook postBuild
    '';

    meta = {
      description = "mecab-ipadic extended with neologisms (NEologd)";
      homepage = "https://github.com/neologd/mecab-ipadic-neologd";
      license = lib.licenses.bsd3;
      platforms = lib.platforms.unix;
    };
  }
